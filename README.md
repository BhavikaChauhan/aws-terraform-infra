# 🏗️ AWS Infrastructure with Terraform — 3-Environment Setup

![Terraform](https://img.shields.io/badge/IaC-Terraform_1.6-7B42BC?style=flat&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?style=flat&logo=amazonaws&logoColor=black)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=flat&logo=githubactions&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)

Production-grade AWS infrastructure as code — **VPC, EC2, S3, IAM, Security Groups** — across 3 isolated environments (dev/staging/prod) with remote state, state locking, and automated `plan`/`apply` via GitHub Actions.

> 🎯 **Portfolio demo** — this mirrors exactly what I deliver to clients as a Cloud Infra Setup service.

---

## 📐 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions                           │
│  Pull Request  →  terraform plan  →  comment on PR         │
│  Merge to main →  terraform apply  (with approval gate)    │
└────────────────────────────┬────────────────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
         ┌────▼────┐   ┌─────▼────┐  ┌─────▼────┐
         │   DEV   │   │ STAGING  │  │   PROD   │
         │VPC+EC2  │   │ VPC+EC2  │  │ VPC+EC2  │
         │t2.micro │   │ t2.micro │  │ t2.micro │
         │1 AZ     │   │  2 AZs   │  │  2 AZs   │
         └────┬────┘   └────┬─────┘  └─────┬────┘
              │             │              │
              └──────────────┴──────────────┘
                             │
                    ┌────────▼────────┐
                    │  Remote State   │
                    │  S3 Bucket      │
                    │  + DynamoDB     │
                    │  (state lock)   │
                    └─────────────────┘

Per-environment AWS resources:
┌────────────────────────────────────────┐
│  VPC (isolated per environment)        │
│  ├── Public Subnets (1–2 AZs)         │
│  │   └── EC2 t2.micro + EIP           │
│  │       └── Nginx → App port 3000    │
│  ├── Private Subnets (future DB/cache) │
│  ├── Internet Gateway                  │
│  └── Route Tables                      │
│                                        │
│  Security Groups                       │
│  ├── App SG: 22, 80, 443, 3000        │
│  └── ALB SG: 80, 443 (ready to scale) │
│                                        │
│  IAM Role (EC2)                        │
│  ├── ECR pull (for Docker images)      │
│  ├── S3 read/write                     │
│  ├── SSM (no SSH needed)              │
│  └── CloudWatch logs                   │
│                                        │
│  S3 Bucket                             │
│  ├── Versioning enabled                │
│  ├── AES256 encryption                 │
│  ├── Public access blocked             │
│  └── Lifecycle: delete old versions    │
│      after 30 days                     │
└────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
aws-terraform-infra/
├── main.tf                        # Root — calls all modules
├── variables.tf                   # Root variable definitions
├── outputs.tf                     # Root outputs
│
├── modules/
│   ├── vpc/                       # VPC, subnets, IGW, routes
│   ├── security-groups/           # App SG, ALB SG
│   ├── ec2/                       # Instance, EIP, billing alarm
│   ├── s3/                        # Bucket, versioning, encryption
│   └── iam/                       # EC2 role, policies, profile
│
├── environments/
│   ├── dev/terraform.tfvars       # Dev: 1 AZ, relaxed security
│   ├── staging/terraform.tfvars   # Staging: mirrors prod
│   └── prod/terraform.tfvars      # Prod: 2 AZs, restricted SSH
│
├── .github/workflows/
│   └── terraform.yml              # Plan on PR, apply on merge
│
├── scripts/
│   └── bootstrap-state.sh         # Create S3 + DynamoDB for state
│
└── COST_ESTIMATE.md               # Monthly cost per environment
```

---

## 🚀 How to Deploy

### Step 1 — Prerequisites
```bash
# Install Terraform
brew install terraform  # Mac
# or: https://developer.hashicorp.com/terraform/install

# Configure AWS CLI
aws configure
# Enter: Access Key, Secret Key, Region (ap-south-1), output (json)
```

### Step 2 — Bootstrap remote state (run once)
```bash
chmod +x scripts/bootstrap-state.sh
./scripts/bootstrap-state.sh

# Then uncomment the backend block in main.tf
# and update with the bucket name from the output
```

### Step 3 — Deploy an environment
```bash
# Dev
terraform init
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"

# Staging
terraform plan -var-file="environments/staging/terraform.tfvars"
terraform apply -var-file="environments/staging/terraform.tfvars"

# Prod
terraform plan -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars"
```

### Step 4 — See what was created
```bash
terraform output environment_summary
# {
#   "ec2_ip"     = "13.235.x.x"
#   "environment" = "dev"
#   "project"    = "myapp"
#   "region"     = "ap-south-1"
#   "s3_bucket"  = "myapp-dev-storage-a1b2c3d4"
# }
```

### Step 5 — Tear down when done (save cost)
```bash
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

---

## 🔁 GitHub Actions Flow

| Trigger | Action |
|---|---|
| Open PR | `terraform fmt` check + `terraform plan` + post plan as PR comment |
| Merge to `main` | `terraform apply` with manual approval gate |

Add these GitHub Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

---

## 💰 Cost

See [COST_ESTIMATE.md](./COST_ESTIMATE.md) for full breakdown.

**TL;DR:** ~$0/month on free tier, ~$28/month for all 3 environments after free tier.

---

## 🧰 Modules

| Module | Resources Created |
|---|---|
| `vpc` | VPC, public/private subnets, IGW, route tables, optional NAT |
| `security-groups` | App SG (22/80/443/3000), ALB SG (80/443) |
| `ec2` | Instance, EIP, billing alarm, user_data bootstrap |
| `s3` | Bucket, versioning, encryption, public access block, lifecycle |
| `iam` | EC2 role, ECR/S3/SSM/CloudWatch policies, instance profile |

---

## 👩‍💻 About

Built by **Bhavika Chauhan** — DevOps & Cloud Engineer.

📅 [Book a free 20-min DevOps audit call](https://calendly.com/bhavikachauhan)
💼 [LinkedIn](https://linkedin.com/in/bhavika-chauhan-276b41332)
✍️ [Medium](https://medium.com/@bhavika.engineered)
