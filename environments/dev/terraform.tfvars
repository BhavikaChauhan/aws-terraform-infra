# ── Dev Environment ────────────────────────────────────────────
# Cheapest config — single AZ, smallest instance, no NAT
project_name = "myapp"
environment  = "dev"
aws_region   = "ap-south-1"

# Single AZ only — saves cost in dev
availability_zones   = ["ap-south-1a"]
public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_cidrs = ["10.0.10.0/24"]

# Free tier instance
instance_type = "t2.micro"
key_name      = "myapp-dev-key"

# Allow SSH from anywhere in dev (restrict in prod!)
allowed_ssh_cidr = "0.0.0.0/0"
