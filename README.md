# thejameskang.com

Personal website automatically synced to AWS S3 via GitHub Actions.

## How It Works

- Every push to the `main` branch automatically syncs files to the S3 bucket
- The GitHub Actions workflow handles the sync process
- Files in `.git/`, `.github/`, `setup/`, `.gitignore`, and `README.md` are excluded from sync

## Setup Files

Setup scripts and documentation are located in the `setup/` folder:
- AWS setup scripts
- IAM configuration guides
- Troubleshooting documentation

## Local Development

1. Clone the repository
2. Make changes to `index.html`, `style.css`, or files in `img/`
3. Commit and push to `main` branch
4. Changes will automatically sync to S3

## Manual Sync

You can also manually trigger the sync workflow from the GitHub Actions tab.

