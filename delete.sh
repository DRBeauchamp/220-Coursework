#!/usr/bin/env bash

# aws ec2 describe-instances
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Step-1" | egrep "VpcId" | cut -f2 -d : | tr -d \",)
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" | egrep "SubnetId" | tail -1 | cut -f2 -d : | tr -d \",)
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" | egrep "igw-" | cut -f2 -d : | tr -d \",)
RT_ID=$(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$SUBNET_ID" | egrep "rtb-" | head -1 | cut -f2 -d : | tr -d \",)
SGroup_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" | egrep "GroupId" | cut -f2 -d : | tr -d \",)

# aws ec2 terminate-instances --instance-ids
# aws ec2 wait instance-terminated --instance-ids

# May need to delete Security Group first, but not when it's the default for that vpc
# aws ec2 delete-security-group --group-id $SGroup_ID

aws ec2 delete-subnet --subnet-id $SUBNET_ID
aws ec2 delete-route-table --route-table-id $RT_ID
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "$VPC_ID $IGW_ID $SUBNET_ID $RT_ID $SGroup_ID have been deleted"
