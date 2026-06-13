# ── Production Environment ─────────────────────────────────────
# Hardened config — restrict SSH, encrypted everything
project_name = "myapp"
environment  = "prod"
aws_region   = "ap-south-1"

availability_zones   = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]
vpc_cidr             = "10.2.0.0/16"

instance_type = "t2.micro"   # Upgrade to t3.small for real prod
key_name      = "myapp-prod-key"

# !! IMPORTANT: Change this to your office/home IP before applying !!
# Find your IP: curl ifconfig.me
allowed_ssh_cidr = "YOUR_IP/32"
