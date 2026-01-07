# Troubleshooting GitHub Actions S3 Sync

## Common Issues and Solutions

### Issue: Workflow fails with "Access Denied" or "Invalid credentials"

**Solution:** Check your GitHub Secrets:
1. Go to your repo: https://github.com/jameskang2357/github-aws-sync
2. Settings → Secrets and variables → Actions
3. Verify you have these 4 secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (e.g., `us-west-2`)
   - `S3_BUCKET_NAME` (e.g., `thejameskang.com`)

### Issue: "Bucket not found" error

**Solution:** 
- Verify the bucket name in `S3_BUCKET_NAME` secret matches exactly (case-sensitive)
- Check the region in `AWS_REGION` matches where your bucket is located

### Issue: "User is not authorized to perform: s3:PutObject"

**Solution:**
- The IAM user needs S3 permissions
- Go to AWS Console → IAM → Users → `github-s3-sync-user`
- Check the Permissions tab has an inline policy with:
  - `s3:PutObject`
  - `s3:GetObject`
  - `s3:DeleteObject`
  - `s3:ListBucket`
- Resource should be: `arn:aws:s3:::YOUR-BUCKET-NAME` and `arn:aws:s3:::YOUR-BUCKET-NAME/*`

### Issue: Workflow fails silently or times out

**Solution:**
- Check the workflow logs in the Actions tab
- Look for specific error messages
- Verify AWS credentials are valid by testing locally:
  ```bash
  aws s3 ls s3://thejameskang.com/
  ```

## How to View Workflow Logs

1. Go to Actions tab in your GitHub repo
2. Click on the failed workflow run (red X)
3. Click on the "deploy" job
4. Expand each step to see detailed logs
5. Look for error messages in red

## Test AWS Credentials Locally

To verify your credentials work:

```bash
# Test listing bucket
aws s3 ls s3://thejameskang.com/

# Test syncing (dry run)
aws s3 sync . s3://thejameskang.com/ --dryrun
```

If these work locally but fail in GitHub Actions, the issue is likely with the GitHub Secrets.

