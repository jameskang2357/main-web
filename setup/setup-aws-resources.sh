#!/bin/bash

# AWS S3 Bucket and IAM User Setup Script
# This script automates the creation of S3 bucket and IAM user for GitHub Actions sync

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed.${NC}"
    echo "Please install it from: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials are not configured.${NC}"
    echo "Please run 'aws configure' first."
    exit 1
fi

echo -e "${GREEN}AWS S3 Bucket and IAM User Setup${NC}"
echo "======================================"
echo ""

# Get user input
read -p "Enter S3 bucket name (must be globally unique): " BUCKET_NAME
read -p "Enter AWS region (e.g., us-east-1, us-west-2): " AWS_REGION
read -p "Enter IAM user name for GitHub Actions (e.g., github-s3-sync-user): " IAM_USER_NAME

# Validate inputs
if [ -z "$BUCKET_NAME" ] || [ -z "$AWS_REGION" ] || [ -z "$IAM_USER_NAME" ]; then
    echo -e "${RED}Error: All fields are required.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Creating S3 bucket: $BUCKET_NAME in region: $AWS_REGION${NC}"

# Create S3 bucket
if aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION" 2>/dev/null; then
    echo -e "${GREEN}✓ S3 bucket created successfully${NC}"
elif aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region us-east-1 2>/dev/null; then
    # us-east-1 doesn't need LocationConstraint
    echo -e "${GREEN}✓ S3 bucket created successfully (us-east-1)${NC}"
else
    echo -e "${YELLOW}Bucket might already exist or there was an error. Continuing...${NC}"
fi

# Enable versioning (optional but recommended)
read -p "Enable versioning on the bucket? (y/n): " ENABLE_VERSIONING
if [ "$ENABLE_VERSIONING" = "y" ] || [ "$ENABLE_VERSIONING" = "Y" ]; then
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled
    echo -e "${GREEN}✓ Versioning enabled${NC}"
fi

echo ""
echo -e "${YELLOW}Creating IAM user: $IAM_USER_NAME${NC}"

# Create IAM user
if aws iam create-user --user-name "$IAM_USER_NAME" 2>/dev/null; then
    echo -e "${GREEN}✓ IAM user created successfully${NC}"
else
    echo -e "${YELLOW}IAM user might already exist. Continuing...${NC}"
fi

# Attach S3 full access policy
echo -e "${YELLOW}Attaching S3 full access policy...${NC}"
aws iam attach-user-policy \
    --user-name "$IAM_USER_NAME" \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
echo -e "${GREEN}✓ Policy attached${NC}"

# Create access keys
echo ""
echo -e "${YELLOW}Creating access keys...${NC}"
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "$IAM_USER_NAME")
ACCESS_KEY_ID=$(echo "$ACCESS_KEY_OUTPUT" | grep -oP '"AccessKeyId":\s*"\K[^"]+')
SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_OUTPUT" | grep -oP '"SecretAccessKey":\s*"\K[^"]+')

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Save these credentials securely!${NC}"
echo ""
echo "AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY"
echo "AWS_REGION=$AWS_REGION"
echo "S3_BUCKET_NAME=$BUCKET_NAME"
echo ""
echo -e "${YELLOW}Add these as GitHub Secrets:${NC}"
echo "1. Go to your GitHub repository"
echo "2. Settings → Secrets and variables → Actions"
echo "3. Add each of the above as repository secrets"
echo ""
echo -e "${RED}⚠️  You won't be able to see the Secret Access Key again!${NC}"
echo ""

