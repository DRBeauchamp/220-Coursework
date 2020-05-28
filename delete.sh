#!/usr/bin/env bash

export AWS_DEFAULT_REGION=us-east-1

# Deletes Step-1 ec2 instance, vpc and all associated resources.
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Step-1" | grep "VpcId" | cut -f4 -d \" )
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" | grep SubnetId | cut -f4 -d \" )
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" | grep "igw-" | cut -f4 -d \" )
RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Step-1" | grep -m 1 "rtb-" | cut -f4 -d \" )
SGROUP_ID=$(aws ec2 describe-security-groups --filters "Name=description,Values=Step-1 security group for SSH access" | grep GroupId | cut -f4 -d \" )
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" "Name=instance-state-name,Values=running" | grep InstanceId | cut -f4 -d \" )

# echo -e "Deleting Step1KeyPair\n"
aws ec2 delete-key-pair --key-name Step1KeyPair
while true; do
    read -p "Is it ok to delete Step1KeyPair.pem from your computer? (Y/N)" YN
    case $YN in
        [Yy]* ) rm -f Step1KeyPair.pem;echo "Deleted Step1KeyPair";break;;
        [Nn]* ) break;;
        * ) echo "Please answer y(es) or n(o).";;
    esac
done

echo -e "Terminating Step-1 instance\nThis could take a few moments..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
echo "$INSTANCE_ID terminated"

aws ec2 delete-security-group --group-id $SGROUP_ID
aws ec2 delete-subnet --subnet-id $SUBNET_ID
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
aws ec2 delete-route-table --route-table-id $RT_ID
aws ec2 delete-vpc --vpc-id $VPC_ID

echo -e "$VPC_ID\n$IGW_ID\n$SUBNET_ID\n$RT_ID\n$SGROUP_ID have all been deleted"
