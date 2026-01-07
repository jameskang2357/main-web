# Manual IAM User Setup for Existing S3 Bucket

Since your current AWS credentials don't have IAM permissions, here's how to set up the IAM user manually in the AWS Console.

## Step 1: Create IAM User

1. Go to AWS Console → IAM
2. Click **"Users"** in the left sidebar
3. Click **"Create user"**
4. Enter username: `github-s3-sync-user` (or your preferred name)
5. Click **"Next"**

## Step 2: Attach Permissions (Option A - Inline Policy for Specific Bucket)

1. Click **"Next"** (skip attaching policies directly)
2. Click **"Create user"**
3. Click on the user you just created
4. Go to **"Permissions"** tab
5. Click **"Add permissions"** → **"Create inline policy"**
6. Click **"JSON"** tab
7. Paste this policy (replace `YOUR-BUCKET-NAME` with your actual bucket name):

```json
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
        "arn:aws:s3:::YOUR-BUCKET-NAME",
        "arn:aws:s3:::YOUR-BUCKET-NAME/*"
      ]
    }
  ]
}
```

8. Click **"Next"**
9. Name the policy: `S3BucketAccess` (or any name)
10. Click **"Create policy"**

## Step 3: Create Access Keys

1. Click on the **"Security credentials"** tab
2. Scroll to **"Access keys"** section
3. Click **"Create access key"**
4. Select **"Application running outside AWS"**
5. Click **"Next"**
6. Optionally add description: "GitHub Actions S3 Sync"
7. Click **"Create access key"**
8. **IMPORTANT**: Copy both:
   - **Access key ID**
   - **Secret access key** (click "Show" if needed)

## Step 4: Add to GitHub Secrets

Go to your GitHub repository:
1. **Settings** → **Secrets and variables** → **Actions**
2. Add these secrets:
   - `AWS_ACCESS_KEY_ID` = [your Access Key ID]
   - `AWS_SECRET_ACCESS_KEY` = [your Secret Access Key]
   - `AWS_REGION` = `us-west-2` (or your bucket's region)
   - `S3_BUCKET_NAME` = [your bucket name, e.g., `thejameskang.com`]

---

## Alternative: Use Full S3 Access (Less Secure)

If you want to use the managed policy instead:

1. When creating the user, select **"Attach policies directly"**
2. Search for `AmazonS3FullAccess`
3. Check the box and attach it
4. Continue with Step 3 above

**Note**: This gives access to ALL S3 buckets, not just your specific one.

