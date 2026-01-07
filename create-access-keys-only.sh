#!/bin/bash

# Create Access Keys for Existing IAM User
# Use this if the IAM user already exists but you need new access keys

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed.${NC}"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials are not configured.${NC}"
    exit 1
fi

echo -e "${GREEN}Create Access Keys for Existing IAM User${NC}"
echo "=========================================="
echo ""

read -p "Enter IAM user name: " IAM_USER_NAME

if [ -z "$IAM_USER_NAME" ]; then
    echo -e "${RED}Error: IAM user name is required.${NC}"
    exit 1
fi

# Check if user exists
if ! aws iam get-user --user-name "$IAM_USER_NAME" &> /dev/null; then
    echo -e "${RED}Error: IAM user '$IAM_USER_NAME' not found.${NC}"
    echo "Please create the user first in AWS Console or use the manual setup guide."
    exit 1
fi

echo -e "${GREEN}✓ User found: $IAM_USER_NAME${NC}"

# Check existing keys
EXISTING_KEYS=$(aws iam list-access-keys --user-name "$IAM_USER_NAME" --query 'AccessKeyMetadata[].AccessKeyId' --output text 2>/dev/null || echo "")
KEY_COUNT=$(echo "$EXISTING_KEYS" | wc -w | tr -d ' ')

if [ "$KEY_COUNT" -ge 2 ]; then
    echo ""
    echo -e "${YELLOW}User already has 2 access keys (AWS limit):${NC}"
    aws iam list-access-keys --user-name "$IAM_USER_NAME" --output table
    echo ""
    read -p "Do you want to delete one and create a new one? (y/n): " DELETE_KEY
    if [ "$DELETE_KEY" = "y" ] || [ "$DELETE_KEY" = "Y" ]; then
        echo ""
        echo -e "${YELLOW}Existing access keys:${NC}"
        aws iam list-access-keys --user-name "$IAM_USER_NAME" --output table
        echo ""
        read -p "Enter the Access Key ID to delete: " KEY_TO_DELETE
        if [ -z "$KEY_TO_DELETE" ]; then
            echo -e "${RED}Error: Access Key ID is required.${NC}"
            exit 1
        fi
        aws iam delete-access-key --user-name "$IAM_USER_NAME" --access-key-id "$KEY_TO_DELETE"
        echo -e "${GREEN}✓ Access key deleted${NC}"
    else
        echo -e "${YELLOW}Cancelled.${NC}"
        exit 0
    fi
fi

# Create new access key
echo ""
echo -e "${YELLOW}Creating new access key...${NC}"
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "$IAM_USER_NAME")
ACCESS_KEY_ID=$(echo "$ACCESS_KEY_OUTPUT" | grep -oP '"AccessKeyId":\s*"\K[^"]+')
SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_OUTPUT" | grep -oP '"SecretAccessKey":\s*"\K[^"]+')

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Access Keys Created!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Save these credentials securely!${NC}"
echo ""
echo "AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY"
echo ""
echo -e "${YELLOW}Add these as GitHub Secrets:${NC}"
echo "1. Go to your GitHub repository"
echo "2. Settings → Secrets and variables → Actions"
echo "3. Add AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
echo ""
echo -e "${RED}⚠️  You won't be able to see the Secret Access Key again!${NC}"
echo ""

