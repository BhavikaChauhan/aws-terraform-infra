#!/bin/bash
# ================================================================
# Bootstrap Remote State — run ONCE before first terraform init
# Creates: S3 bucket (state) + DynamoDB table (locking)
# ================================================================
set -e

REGION="ap-south-1"
PROJECT="myapp"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="${PROJECT}-tfstate-${ACCOUNT_ID}"
DYNAMO_TABLE="terraform-state-lock"

echo "🚀 Bootstrapping Terraform remote state..."

# ── S3 bucket for state ────────────────────────────────────────
echo "📦 Creating state bucket: ${BUCKET_NAME}"
aws s3api create-bucket \
  --bucket ${BUCKET_NAME} \
  --region ${REGION} \
  --create-bucket-configuration LocationConstraint=${REGION} \
  2>/dev/null || echo "Bucket already exists"

# Enable versioning (critical — lets you recover corrupted state)
aws s3api put-bucket-versioning \
  --bucket ${BUCKET_NAME} \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket ${BUCKET_NAME} \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}
    }]
  }'

# Block all public access
aws s3api put-public-access-block \
  --bucket ${BUCKET_NAME} \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "✅ State bucket ready: ${BUCKET_NAME}"

# ── DynamoDB table for state locking ──────────────────────────
echo "🔒 Creating DynamoDB lock table: ${DYNAMO_TABLE}"
aws dynamodb create-table \
  --table-name ${DYNAMO_TABLE} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ${REGION} \
  2>/dev/null || echo "Table already exists"

echo "✅ DynamoDB lock table ready"

echo ""
echo "✅ ════════════════════════════════════════════════════"
echo "   Now uncomment the backend block in main.tf"
echo "   and update it with:"
echo ""
echo "   bucket         = \"${BUCKET_NAME}\""
echo "   dynamodb_table = \"${DYNAMO_TABLE}\""
echo "   region         = \"${REGION}\""
echo ""
echo "   Then run: terraform init"
echo "════════════════════════════════════════════════════"
