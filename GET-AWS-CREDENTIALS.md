# How to Get AWS Access Key ID and Secret Access Key

## Prerequisites
- An AWS account (sign up at https://aws.amazon.com if you don't have one)

## Method 1: Create IAM User and Access Keys (Recommended)

This is the **recommended approach** for security. You'll create a dedicated IAM user specifically for GitHub Actions.

### Step 1: Log into AWS Console
1. Go to https://console.aws.amazon.com
2. Sign in with your AWS account credentials

### Step 2: Navigate to IAM
1. In the AWS Console, search for "IAM" in the top search bar
2. Click on "IAM" (Identity and Access Management)

### Step 3: Create a New User
1. In the left sidebar, click **"Users"**
2. Click the **"Create user"** button (top right)
3. Enter a username (e.g., `github-s3-sync-user`)
4. Click **"Next"**

### Step 4: Attach Permissions
1. Select **"Attach policies directly"**
2. Search for `AmazonS3FullAccess` in the search box
3. Check the box next to **"AmazonS3FullAccess"**
4. Click **"Next"**
5. Review and click **"Create user"**

### Step 5: Create Access Keys
1. Click on the user you just created (the username you entered)
2. Click on the **"Security credentials"** tab
3. Scroll down to **"Access keys"** section
4. Click **"Create access key"**
5. Select **"Application running outside AWS"** (this is for GitHub Actions)
6. Check the confirmation box and click **"Next"**
7. Optionally add a description (e.g., "GitHub Actions S3 Sync")
8. Click **"Create access key"**

### Step 6: Save Your Credentials
**⚠️ IMPORTANT: This is the ONLY time you'll see the Secret Access Key!**

You'll see:
- **Access key ID** - Copy this immediately
- **Secret access key** - Copy this immediately (click "Show" if needed)

**Save these securely!** You won't be able to see the secret key again.

---

## Method 2: Use Root Account Credentials (Not Recommended)

**⚠️ WARNING: Using root account credentials is NOT recommended for security reasons.**

If you absolutely must use root account credentials:
1. Log into AWS Console
2. Click on your account name (top right)
3. Click **"Security credentials"**
4. Scroll to **"Access keys"**
5. Click **"Create access key"**

**However, it's much better to use Method 1 (IAM user) for security!**

---

## Method 3: Use Existing Credentials (If You Already Have Them)

If you already have AWS credentials:
1. You can use them to run the setup script: `./setup-aws-resources.sh`
2. The script will create a new IAM user and access keys specifically for GitHub Actions
3. You'll use your existing credentials to authenticate, and the script will create the new ones

---

## What to Do Next

Once you have your **Access Key ID** and **Secret Access Key**:

1. **Configure AWS CLI** (if you want to use the setup script):
   ```bash
   aws configure
   ```
   Enter:
   - AWS Access Key ID: [paste your Access Key ID]
   - AWS Secret Access Key: [paste your Secret Access Key]
   - Default region: [e.g., us-east-1]
   - Default output format: json

2. **Or add them directly to GitHub Secrets**:
   - Go to your GitHub repository
   - Settings → Secrets and variables → Actions
   - Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as secrets

---

## Security Best Practices

- ✅ Use IAM users instead of root account
- ✅ Grant only the minimum permissions needed (S3 access only)
- ✅ Never commit credentials to git
- ✅ Rotate access keys regularly
- ✅ Use different credentials for different purposes

