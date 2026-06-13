output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "ec2_public_ip" {
  description = "EC2 instance public IP"
  value       = module.ec2.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "app_security_group_id" {
  description = "App security group ID"
  value       = module.security_groups.app_sg_id
}

output "environment_summary" {
  description = "Summary of what was deployed"
  value = {
    environment  = var.environment
    region       = var.aws_region
    project      = var.project_name
    ec2_ip       = module.ec2.public_ip
    s3_bucket    = module.s3.bucket_name
  }
}
