#!/usr/bin/env bash
# OPTIONAL local shortcut. The pipeline (see codepipeline.tf's frontend
# CodeBuild + S3 deploy action) already does this automatically on every
# GitHub push - use this script only when you want to test a frontend change
# in seconds instead of waiting ~2-3 minutes for a full pipeline run.
set -euo pipefail

cd "$(dirname "$0")/.."

BUCKET=$(terraform output -raw assets_bucket_name)
PRODUCT_URL="http://$(terraform output -raw product_alb_dns)"
ORDER_URL="http://$(terraform output -raw order_alb_dns)"
SITE_URL=$(terraform output -raw storefront_website_url)

echo "Bucket:       $BUCKET"
echo "Product API:  $PRODUCT_URL"
echo "Order API:    $ORDER_URL"

# Build a temp copy with the real API URLs injected, so the source file in
# git keeps its placeholder values instead of a live environment's URLs.
TMP_DIR=$(mktemp -d)
cp -r frontend/* "$TMP_DIR"/

sed -i.bak \
  -e "s|http://REPLACE-WITH-PRODUCT-ALB-DNS-NAME|${PRODUCT_URL}|g" \
  -e "s|http://REPLACE-WITH-ORDER-ALB-DNS-NAME|${ORDER_URL}|g" \
  "$TMP_DIR/app.js"
rm -f "$TMP_DIR/app.js.bak"

aws s3 sync "$TMP_DIR" "s3://${BUCKET}" --delete

rm -rf "$TMP_DIR"

echo ""
echo "Deployed. Open your storefront at:"
echo "$SITE_URL"
