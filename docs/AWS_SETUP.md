# AWS and GitHub setup

This file records the cloud-side configuration required by the assignment. Nothing in this repository creates AWS resources automatically.

## GitHub secrets

| Secret | Purpose |
|---|---|
| `DOCKERHUB_USERNAME` | Private Docker Hub repository owner |
| `DOCKERHUB_TOKEN` | Docker Hub read/write access token |
| `MONGODB_URI` | Atlas connection string, synchronized to SSM |
| `AWS_ROLE_ARN` | GitHub OIDC deployment-role ARN |
| `ASG_NAME` | `student-api-asg` |
| `ALB_DNS_NAME` | Public ALB DNS name, without `http://` |

Do not add `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY`.

## Required infrastructure

Use `us-east-1` consistently.

1. Create `alb-sg`: inbound HTTP/80 from `0.0.0.0/0`; outbound all.
2. Create `ec2-sg`: inbound TCP/3000 from `alb-sg` only; outbound all. Do not open port 22.
3. Create EC2 role/profile `student-api-ec2-role` with `AmazonSSMManagedInstanceCore` and permission to read `arn:aws:ssm:*:*:parameter/student-api/*`.
4. Store `/student-api/dockerhub/username` as `String` and `/student-api/dockerhub/token` as `SecureString`. The workflow creates `/student-api/mongodb/uri`.
5. Create launch template `student-api-lt`: Ubuntu 22.04, `t3.micro`, no key pair, the EC2 profile, and `ec2-sg`. User data installs and enables Docker plus AWS CLI v2.
6. Create target group `student-api-tg`: instance target, HTTP/3000, health path `/health`.
7. Create internet-facing ALB `student-api-alb` in two public subnets, with `alb-sg` and HTTP/80 forwarded to the target group.
8. Create `student-api-asg` from the launch template in the same two AZs, attach the target group, use ELB health checks, 120-second grace, desired/minimum 1 and maximum 2.
9. Add GitHub's OIDC provider (`https://token.actions.githubusercontent.com`, audience `sts.amazonaws.com`). Create `student-api-github-actions-role`, restrict `sub` to this repository, and allow SSM SendCommand/status calls, SSM PutParameter under `/student-api/*`, and ASG describe.

The exact trust and permissions policy examples are in `LAB.md.docx`. Replace every placeholder before use.

## User data

```bash
#!/bin/bash
set -euo pipefail
apt-get update -y
apt-get install -y docker.io unzip curl jq
systemctl enable --now docker
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip
```

Before provisioning anything, use the workflow's default cloud-free mode. If real evidence is required, create the infrastructure and manually run the workflow with `deploy=true`, capture the evidence listed in `SUBMISSION.md`, and then follow `CLEANUP.md`.
