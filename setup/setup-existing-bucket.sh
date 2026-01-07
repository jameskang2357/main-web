#!/bin/bash

# AWS IAM User Setup for Existing S3 Bucket
# This script creates an IAM user and access keys for an existing S3 bucket

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

echo -e "${GREEN}AWS IAM User Setup for Existing S3 Bucket${NC}"
echo "================================================"
echo ""

# Get user input
read -p "Enter existing S3 bucket name: " BUCKET_NAME
read -p "Enter AWS region (e.g., us-east-1, us-west-2): " AWS_REGION
read -p "Enter IAM user name for GitHub Actions (e.g., github-s3-sync-user): " IAM_USER_NAME

# Validate inputs
if [ -z "$BUCKET_NAME" ] || [ -z "$AWS_REGION" ] || [ -z "$IAM_USER_NAME" ]; then
    echo -e "${RED}Error: All fields are required.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Verifying bucket exists: $BUCKET_NAME${NC}"

# Verify bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo -e "${GREEN}✓ Bucket verified${NC}"
else
    echo -e "${RED}Error: Bucket '$BUCKET_NAME' not found or you don't have access to it.${NC}"
    echo "Please verify the bucket name and your permissions."
    exit 1
fi

# Get bucket region to verify
BUCKET_REGION=$(aws s3api get-bucket-location --bucket "$BUCKET_NAME" --output text 2>/dev/null || echo "us-east-1")
if [ "$BUCKET_REGION" = "None" ]; then
    BUCKET_REGION="us-east-1"
fi

echo -e "${GREEN}✓ Bucket region: $BUCKET_REGION${NC}"

echo ""
echo -e "${YELLOW}Creating IAM user: $IAM_USER_NAME${NC}"

# Create IAM user
if aws iam create-user --user-name "$IAM_USER_NAME" 2>/dev/null; then
    echo -e "${GREEN}✓ IAM user created successfully${NC}"
else
    echo -e "${YELLOW}IAM user might already exist. Continuing...${NC}"
fi

# Create inline policy for this specific bucket
POLICY_NAME="S3BucketAccess-${IAM_USER_NAME}"
POLICY_DOC=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${BUCKET_NAME}",
        "arn:aws:s3:::${BUCKET_NAME}/*"
      ]
    }
  ]
}
EOF
)

echo -e "${YELLOW}Creating policy for bucket access...${NC}"

# Delete existing policy if it exists (to update it)
aws iam delete-user-policy --user-name "$IAM_USER_NAME" --policy-name "$POLICY_NAME" 2>/dev/null || true

# Create the policy
echo "$POLICY_DOC" > /tmp/bucket-policy.json
aws iam put-user-policy \
    --user-name "$IAM_USER_NAME" \
    --policy-name "$POLICY_NAME" \
    --policy-document file:///tmp/bucket-policy.json
rm /tmp/bucket-policy.json

echo -e "${GREEN}✓ Policy attached (scoped to bucket: $BUCKET_NAME)${NC}"

# Create access keys
echo ""
echo -e "${YELLOW}Creating access keys...${NC}"

# Check if user already has 2 access keys (AWS limit)
EXISTING_KEYS=$(aws iam list-access-keys --user-name "$IAM_USER_NAME" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null || echo "")
KEY_COUNT=$(echo "$EXISTING_KEYS" | wc -w | tr -d ' ')

if [ "$KEY_COUNT" -ge 2 ]; then
    echo -e "${YELLOW}User already has 2 access keys (AWS limit).${NC}"
    echo -e "${YELLOW}Existing access keys:${NC}"
    aws iam list-access-keys --user-name "$IAM_USER_NAME" --output table
    echo ""
    read -p "Do you want to delete an existing key and create a new one? (y/n): " DELETE_KEY
    if [ "$DELETE_KEY" = "y" ] || [ "$DELETE_KEY" = "Y" ]; then
        echo -e "${YELLOW}Please enter the Access Key ID to delete:${NC}"
        read -p "Access Key ID: " KEY_TO_DELETE
        aws iam delete-access-key --user-name "$IAM_USER_NAME" --access-key-id "$KEY_TO_DELETE"
        echo -e "${GREEN}✓ Access key deleted${NC}"
    else
        echo -e "${YELLOW}Using existing access keys.${NC}"
        echo -e "${YELLOW}To view existing keys, run:${NC}"
        echo "aws iam list-access-keys --user-name $IAM_USER_NAME"
        exit 0
    fi
fi

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
echo "AWS_REGION=$BUCKET_REGION"
echo "S3_BUCKET_NAME=$BUCKET_NAME"
echo ""
echo -e "${YELLOW}Add these as GitHub Secrets:${NC}"
echo "1. Go to your GitHub repository"
echo "2. Settings → Secrets and variables → Actions"
echo "3. Add each of the above as repository secrets"
echo ""
echo -e "${GREEN}✓ IAM user has permissions for bucket: $BUCKET_NAME${NC}"
echo -e "${RED}⚠️  You won't be able to see the Secret Access Key again!${NC}"
echo ""

