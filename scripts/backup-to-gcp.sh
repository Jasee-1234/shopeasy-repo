#!/usr/bin/env bash
# Syncs the S3 assets bucket to its GCS backup bucket. This is the piece
# that's still manual/scheduled rather than triggered by the pipeline -
# see README.md section 8 for why. Run it by hand, or wire it into a cron
# job / scheduled GitHub Actions workflow / Lambda for a real schedule.
#
# Requires: gcloud CLI installed and authenticated as the service account
# Terraform created (gcp_backup module), or your own account with write
# access to the backup bucket.
set -euo pipefail

cd "$(dirname "$0")/.."

S3_BUCKET=$(terraform output -raw assets_bucket_name)
GCS_BUCKET=$(terraform output -raw gcp_backup_bucket_name)

echo "Source (S3):      s3://${S3_BUCKET}"
echo "Destination (GCS): gs://${GCS_BUCKET}"
echo ""

# Pull everything from S3 locally first, then push to GCS - simplest
# reliable path without needing direct S3<->GCS credentials on either side.
TMP_DIR=$(mktemp -d)
echo "Downloading from S3..."
aws s3 sync "s3://${S3_BUCKET}" "$TMP_DIR" --quiet

echo "Uploading to GCS..."
gcloud storage rsync "$TMP_DIR" "gs://${GCS_BUCKET}" --recursive

rm -rf "$TMP_DIR"
echo ""
echo "Backup complete: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
