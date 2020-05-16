#!/usr/bin/env bash

# Create a vpc and tag it
RESULTS=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output json | egrep "VpcId" | cut -f2 -d : | tr -d \",)
VPC_ID=$RESULTS
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value="Step-1"

# Create an internet gateway and attach it to the vpc
aws ec2 create-internet-gateway
IGW_ID=$(aws ec2 describe-internet-gateways | egrep "igw-" | cut -f2 -d : | tr -d \",)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value="Step-1"

# Create a subnet within the vpc and modify it so that new instances within it will be public on launch
aws ec2 create-subnet --cidr-block 10.0.1.0/24 --vpc-id $VPC_ID
SUBNET_ID=$(aws ec2 describe-subnets | egrep "SubnetId" | tail -1 | cut -f2 -d : | tr -d \",)
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value="Step-1"

# Create a route table in the vpc
aws ec2 create-route-table --vpc-id $VPC_ID
RT_ID=$(aws ec2 describe-route-tables | egrep "rtb-" | head -1 | cut -f2 -d : | tr -d \",)
aws ec2 create-tags --resources $RT_ID --tags Key=Name,Value="Step-1"

# Create a route within
aws ec2 create-route --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --route-table-id $RT_ID
aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET_ID

echo "These resources were just created: "
echo -e $VPC_ID\n $IGW_ID\n $SUBNET_ID\n $RT_ID\n
# $SGroup_ID


# aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "State"


# NEED TO PUT A TIMER HERE BEFORE STARTING THE INSTANCE
# In order to create an ec2 instance
# Create a key pair
# aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem
# chmod 400 MyKeyPair.pem

# Create a security group and allow SSH access from anywhere, (Not advisable in production)
# aws ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id $VPC_ID
# SGroup_ID=$(aws ec2 describe-security-groups --filters Name=description,Values="Security group for SSH access" | egrep "GroupId" | cut -f2 -d : | tr -d \",)
# aws ec2 authorize-security-group-ingress --group-id $SGroup_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

# aws ec2 run-instances --image-id ami-085925f297f89fce1 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids $SGroup_ID --subnet-id $SUBNET_ID
# aws ec2 describe-instances
