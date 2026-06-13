# ── Staging Environment ────────────────────────────────────────
# Mirrors prod — catches issues before they hit real users
project_name = "myapp"
environment  = "staging"
aws_region   = "ap-south-1"

# Two AZs — like prod, for realistic testing
availability_zones   = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
vpc_cidr             = "10.1.0.0/16"

instance_type = "t2.micro"
key_name      = "myapp-staging-key"

allowed_ssh_cidr = "0.0.0.0/0"
