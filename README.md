# Full-Stack ECS Fargate + RDS Project

A realistic beginner-friendly AWS deployment project:

Browser
  -> Internet-facing Application Load Balancer
      -> `/` and static files -> Frontend ECS Fargate service (Nginx)
      -> `/api/*` -> Backend ECS Fargate service (Flask)
                                  -> PostgreSQL Amazon RDS (private)

AWS components used:
- VPC with public and private subnets across 2 AZs
- Internet Gateway
- NAT Gateway(s)
- Application Load Balancer
- ECS Cluster
- ECS Fargate
- ECR
- Two ECS services: frontend + backend
- RDS PostgreSQL
- Secrets Manager
- CloudWatch Logs
- IAM task execution/task roles
- ECS Service Auto Scaling
- Health checks
- HTTPS with ACM (deployment step)
- Route 53 DNS (optional deployment step)
- GitHub Actions CI/CD (later lab)

## Application

The demo is a small "Cloud Notes" application.

Frontend:
- Responsive HTML/CSS/JavaScript
- Create a note
- List notes
- Delete a note
- Calls `/api/notes`

Backend:
- Flask
- SQLAlchemy
- PostgreSQL
- Health endpoint: `/api/health`
- CRUD endpoints under `/api/notes`

## Run locally

Requirements:
- Docker Desktop

```bash
docker compose up --build
```

Open:
http://localhost:8080

Backend directly:
http://localhost:5000/api/health

## AWS deployment order

1. Create VPC/network
2. Create security groups
3. Create RDS PostgreSQL
4. Create Secrets Manager secret
5. Create ECR repositories
6. Build and push frontend/backend images
7. Create ECS cluster
8. Create IAM roles
9. Create ALB + target groups + listener rules
10. Create ECS task definitions
11. Create ECS services
12. Configure autoscaling
13. Configure CloudWatch
14. Add HTTPS/ACM
15. Add Route 53
16. Add GitHub Actions CI/CD
17. Test scaling and rolling deployment

Important:
- ECS tasks should run in private subnets.
- RDS should not be publicly accessible.
- ALB is the public entry point.
- Backend security group accepts traffic only from the ALB security group.
- RDS security group accepts PostgreSQL only from the backend security group.
