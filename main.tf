terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state in S3 + DynamoDB locking
  # Uncomment after running scripts/bootstrap-state.sh
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket-name"
  #   key            = "infra/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "bhavika-chauhan"
    }
  }
}

# ── VPC ────────────────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ── Security Groups ────────────────────────────────────────────
module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# ── IAM ────────────────────────────────────────────────────────
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  s3_bucket_arn = module.s3.bucket_arn
}

# ── EC2 ────────────────────────────────────────────────────────
module "ec2" {
  source = "./modules/ec2"

  project_name        = var.project_name
  environment         = var.environment
  instance_type       = var.instance_type
  ami_id              = var.ami_id
  key_name            = var.key_name
  subnet_id           = module.vpc.public_subnet_ids[0]
  security_group_ids  = [module.security_groups.app_sg_id]
  iam_instance_profile = module.iam.instance_profile_name

  depends_on = [module.vpc, module.security_groups, module.iam]
}

# ── ECR ────────────────────────────────────────────────────────
module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
  repo_name    = var.ecr_repo_name
}

# ── S3 ─────────────────────────────────────────────────────────
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}
