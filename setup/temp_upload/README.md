# GitHub to AWS S3 Sync Setup

This project is configured to automatically sync files to an AWS S3 bucket whenever you push changes to the main branch.

## Prerequisites

1. An AWS account
2. An S3 bucket created in your AWS account
3. An IAM user with S3 permissions

## Setup Instructions

### Step 1: Create an S3 Bucket

1. Log in to the AWS Console
2. Navigate to S3 service
3. Click "Create bucket"
4. Choose a unique bucket name (e.g., `my-github-sync-bucket`)
5. Select your preferred region
6. Click "Create bucket"

### Step 2: Create an IAM User with S3 Permissions

1. Go to IAM in the AWS Console
2. Click "Users" → "Create user"
3. Enter a username (e.g., `github-s3-sync-user`)
4. Click "Next"
5. Select "Attach policies directly"
6. Search for and select `AmazonS3FullAccess` (or create a custom policy with only the permissions you need)
7. Click "Next" → "Create user"

### Step 3: Create Access Keys

1. Click on the user you just created
2. Go to the "Security credentials" tab
3. Click "Create access key"
4. Select "Application running outside AWS"
5. Click "Next" → "Create access key"
6. **IMPORTANT**: Copy both the Access Key ID and Secret Access Key immediately (you won't be able to see the secret again)

### Step 4: Add Secrets to GitHub

1. Go to your GitHub repository
2. Click "Settings" → "Secrets and variables" → "Actions"
3. Click "New repository secret" and add the following secrets:

   - **Name**: `AWS_ACCESS_KEY_ID`
     **Value**: Your IAM user's Access Key ID

   - **Name**: `AWS_SECRET_ACCESS_KEY`
     **Value**: Your IAM user's Secret Access Key

   - **Name**: `AWS_REGION`
     **Value**: Your AWS region (e.g., `us-east-1`, `us-west-2`, `eu-west-1`)

   - **Name**: `S3_BUCKET_NAME`
     **Value**: Your S3 bucket name (e.g., `my-github-sync-bucket`)

### Step 5: Customize the Workflow (Optional)

Edit `.github/workflows/s3-sync.yml` to:
- Change the branch name from `main` to `master` if needed
- Modify the `--exclude` patterns to control which files are synced
- Remove `--delete` flag if you don't want to remove files from S3 that are deleted locally

## How It Works

- Every push to the `main` branch triggers the workflow
- The workflow uses AWS CLI to sync your repository files to the S3 bucket
- Files in `.git/`, `.github/`, `.gitignore`, and `README.md` are excluded from sync
- You can also manually trigger the workflow from the "Actions" tab in GitHub

## Security Best Practices

- Never commit AWS credentials to your repository
- Use IAM policies with least privilege (only grant S3 permissions needed)
- Regularly rotate your access keys
- Consider using AWS IAM roles with OIDC for better security (more advanced setup)

## Troubleshooting

- **Workflow fails with "Access Denied"**: Check that your IAM user has the correct S3 permissions
- **Bucket not found**: Verify the bucket name in your GitHub secret matches exactly
- **Region mismatch**: Ensure the AWS_REGION secret matches where your bucket is located

