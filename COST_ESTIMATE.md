# 💰 AWS Cost Estimate

This document shows the estimated monthly AWS cost for each environment.
Clients appreciate knowing their infrastructure costs upfront.

---

## Dev Environment

| Resource | Type | Hrs/mo | Unit Cost | Monthly Cost |
|---|---|---|---|---|
| EC2 Instance | t2.micro | 730 | $0.0116/hr | ~$8.50 |
| EIP (Elastic IP) | — | — | $0.005/hr (if unattached) | ~$0 |
| S3 Storage | < 5GB | — | $0.023/GB | ~$0.12 |
| Data Transfer | < 1GB out | — | $0.09/GB | ~$0.09 |
| **Total** | | | | **~$9/mo** |

> ✅ **Free tier:** EC2 t2.micro is free for 12 months (750 hrs/mo). Dev cost = ~$0 for first year.

---

## Staging Environment

| Resource | Type | Hrs/mo | Unit Cost | Monthly Cost |
|---|---|---|---|---|
| EC2 Instance | t2.micro | 730 | $0.0116/hr | ~$8.50 |
| EIP | — | — | — | ~$0 |
| S3 Storage | < 5GB | — | $0.023/GB | ~$0.12 |
| Data Transfer | < 5GB out | — | $0.09/GB | ~$0.45 |
| **Total** | | | | **~$9/mo** |

---

## Production Environment

| Resource | Type | Hrs/mo | Unit Cost | Monthly Cost |
|---|---|---|---|---|
| EC2 Instance | t2.micro | 730 | $0.0116/hr | ~$8.50 |
| EIP | — | — | — | ~$0 |
| S3 Storage | ~10GB | — | $0.023/GB | ~$0.23 |
| Data Transfer | ~10GB out | — | $0.09/GB | ~$0.90 |
| CloudWatch | Basic | — | Free tier | ~$0 |
| **Total** | | | | **~$10/mo** |

---

## All 3 Environments Combined

| | Dev | Staging | Prod | **Total** |
|---|---|---|---|---|
| Estimated/mo | ~$9 | ~$9 | ~$10 | **~$28/mo** |
| Free tier (yr 1) | ~$0 | ~$0 | ~$1 | **~$1/mo** |

---

## Cost Optimisation Tips

- **Stop instances when not in use** — EC2 only charges when running. Stop dev/staging overnight = 60% savings.
- **Use Savings Plans** — commit to 1yr for ~30% discount on prod.
- **S3 lifecycle rules** — already configured in Terraform to delete old versions after 30 days.
- **Billing alarm** — already set up via Terraform at $5 threshold.
- **NAT Gateway disabled by default** — enabling it adds ~$32/mo per environment. Only enable for prod when needed.

---

*Prices based on AWS ap-south-1 (Mumbai) region, May 2025. Actual costs may vary.*
