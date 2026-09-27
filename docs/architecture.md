# Production-style architecture

Internet
   |
   v
[Internet-facing ALB]
   | \
   |  \
 /     /api/*
 |       |
 v       v
[Frontend ECS]   [Backend ECS]
[Nginx]           [Flask/Gunicorn]
                      |
                      v
                [RDS PostgreSQL]
                 private subnet

Supporting services:
- ECR: stores images
- Secrets Manager: DB credentials
- CloudWatch Logs: application logs
- IAM: task execution/task permissions
- Application Auto Scaling: ECS task count
- ACM: TLS certificate
- Route 53: DNS

Security group flow:

Internet -> ALB SG : 80/443
ALB SG -> Frontend SG : 80
ALB SG -> Backend SG : 5000
Backend SG -> RDS SG : 5432

RDS has no public access.

ECS tasks are in private subnets and normally have no public IP.
