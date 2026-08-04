# AWS cleanup and cost-control checklist

No AWS resources are created by local validation or the workflow's default manual `deploy=false` path. Pushes to `main` perform a real deployment when the documented infrastructure and secrets exist, so follow this teardown checklist after collecting evidence.

For a real deployment, first run `scripts/aws-inventory.sh` to capture what exists. Delete only resources whose names and tags identify this lab, in this order:

1. Set `student-api-asg` minimum and desired capacity to zero, then delete the ASG.
2. Delete `student-api-alb`, then wait until it no longer exists.
3. Delete listener/target group `student-api-tg`.
4. Delete launch template `student-api-lt` and any manually created EC2 instances for the lab.
5. Delete SSM parameters below `/student-api/`.
6. Delete `ec2-sg` and `alb-sg` after dependencies have disappeared.
7. Remove the EC2 instance profile, detach/delete its policies, and delete `student-api-ec2-role`.
8. Detach/delete the GitHub Actions role and its inline policy. Delete the GitHub OIDC provider only if no other repository uses it.
9. Delete the private Docker Hub repository and revoke its token if they were created solely for this lab.
10. Remove the lab secrets from GitHub and delete/disable the Atlas database user, network allow-list entry and cluster if they are lab-only.

Run the inventory script again. Confirm there are no lab ALBs, target groups, ASGs, instances, launch templates, SSM parameters, or security groups. Also check AWS Billing/Cost Explorer because resource deletion and billing visibility are not instantaneous.

Never run broad account-wide deletion commands. The inventory script is intentionally read-only; teardown remains explicit so unrelated resources are protected.
