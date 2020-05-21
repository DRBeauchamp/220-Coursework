#!/usr/bin/env bash

# Deletes Step-1 ec2 instance, vpc and all associated resources.
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Step-1" | egrep "VpcId" | cut -f2 -d : | tr -d \", | cut -d ' ' -f2)
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" | egrep "SubnetId" | tail -1 | cut -f2 -d : | tr -d \", | cut -d ' ' -f2)
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" | egrep "igw-" | cut -f2 -d : | tr -d \", | cut -d ' ' -f2)
RT_ID=$(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$SUBNET_ID" | egrep "rtb-" | head -1 | cut -f2 -d : | tr -d \", | cut -d ' ' -f2)
SGROUP_ID=$(aws ec2 describe-security-groups --filters "Name=description,Values=Step-1 security group for SSH access" | egrep "GroupId" | cut -f2 -d : | tr -d \", | cut -d ' ' -f2)
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" | egrep "InstanceId" | cut -f2 -d : | tr -d \", | cut -d ' ' -f2)

aws ec2 delete-key-pair --key-name Step1KeyPair
rm -f Step1KeyPair.pem
echo "Deleted Step1KeyPair"

aws ec2 terminate-instances --instance-ids $INSTANCE_ID
echo -e "terminating instance\nPlease wait..."
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
echo "$INSTANCE_ID terminated"

aws ec2 delete-security-group --group-id $SGROUP_ID
aws ec2 delete-subnet --subnet-id $SUBNET_ID
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
aws ec2 delete-route-table --route-table-id $RT_ID
aws ec2 delete-vpc --vpc-id $VPC_ID

echo -e "$VPC_ID\n$IGW_ID\n$SUBNET_ID\n$RT_ID\n$SGROUP_ID have all been deleted"
