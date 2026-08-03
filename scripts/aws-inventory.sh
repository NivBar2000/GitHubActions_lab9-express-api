#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
PREFIX="${LAB_PREFIX:-student-api}"

echo "Read-only inventory for prefix '$PREFIX' in region '$REGION'"
aws sts get-caller-identity

echo "== Auto Scaling groups =="
aws autoscaling describe-auto-scaling-groups --region "$REGION" \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName, \`$PREFIX\`)].{Name:AutoScalingGroupName,Desired:DesiredCapacity,Instances:Instances[*].InstanceId}" --output table

echo "== Load balancers =="
aws elbv2 describe-load-balancers --region "$REGION" \
  --query "LoadBalancers[?contains(LoadBalancerName, \`$PREFIX\`)].{Name:LoadBalancerName,DNS:DNSName,State:State.Code}" --output table

echo "== Target groups =="
aws elbv2 describe-target-groups --region "$REGION" \
  --query "TargetGroups[?contains(TargetGroupName, \`$PREFIX\`)].{Name:TargetGroupName,Port:Port,ARN:TargetGroupArn}" --output table

echo "== EC2 instances =="
aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Name,Values=$PREFIX*" "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name,Name:Tags[?Key==`Name`]|[0].Value}' --output table

echo "== Launch templates =="
aws ec2 describe-launch-templates --region "$REGION" \
  --filters "Name=launch-template-name,Values=$PREFIX*" \
  --query 'LaunchTemplates[].{Name:LaunchTemplateName,Id:LaunchTemplateId}' --output table

echo "== SSM parameters =="
aws ssm describe-parameters --region "$REGION" \
  --parameter-filters "Key=Name,Option=BeginsWith,Values=/$PREFIX/" \
  --query 'Parameters[].{Name:Name,Type:Type}' --output table

echo "== Security groups =="
aws ec2 describe-security-groups --region "$REGION" \
  --filters "Name=group-name,Values=$PREFIX*,alb-sg,ec2-sg" \
  --query 'SecurityGroups[].{Name:GroupName,Id:GroupId,Vpc:VpcId}' --output table

echo "Inventory finished. This script did not change AWS state."
