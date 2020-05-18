#!/usr/bin/env bash

# Creates an AWS ec2 instance from scratch on a new vpc with all associated resources needed for public internet ssh and http access:
# All resources are tagged "Step-1"

# Create a vpc and tag it
RESULTS=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output json | egrep "VpcId" | cut -f2 -d : | tr -d \",)
VPC_ID=$RESULTS
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value="Step-1"
aws ec2 describe-vpcs --vpc-id $VPC_ID

# Create an internet gateway and attach it to the vpc
RESULTS=$(aws ec2 create-internet-gateway | egrep "igw-" | cut -f2 -d : | tr -d \",)
IGW_ID=$RESULTS
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value="Step-1"
aws ec2 describe-internet-gateways --internet-gateway-id $IGW_ID

# Create a subnet within the vpc and modify it so that new instances within it will be public on launch
RESULTS=$(aws ec2 create-subnet --cidr-block 10.0.1.0/24 --vpc-id $VPC_ID | egrep "SubnetId" | cut -f2 -d : | tr -d \",)
SUBNET_ID=$RESULTS
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value="Step-1"
aws ec2 describe-subnets --subnet-id $SUBNET_ID

# Create a route table in the vpc
RESULTS=$(aws ec2 create-route-table --vpc-id $VPC_ID | egrep "rtb-" | cut -f2 -d : | tr -d \",)
RT_ID=$RESULTS
aws ec2 create-tags --resources $RT_ID --tags Key=Name,Value="Step-1"
aws ec2 describe-route-tables --route-table-id $RT_ID

# Create a route to the internet gateway and attach table to subnet
aws ec2 create-route --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --route-table-id $RT_ID
aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET_ID

aws ec2 wait vpc-available --vpc-ids $VPC_ID
echo "Step-1 $VPC_ID $IGW_ID $SUBNET_ID $RT_ID are ready"

# Create a new key pair
aws ec2 create-key-pair --key-name Step1KeyPair --query 'KeyMaterial' --output text > Step1KeyPair.pem
chmod 400 Step1KeyPair.pem
aws ec2 wait key-pair-exists --key-names Step1KeyPair
KEYPAIR_ID=$(aws ec2 describe-key-pairs  --key-names Step1KeyPair | egrep "KeyPairId" | cut -f2 -d : | tr -d \",)
echo "Step1KeyPair created"

# Create a security group and allow SSH and HTTP access from anywhere. NOTE: not advisable in production!
aws ec2 create-security-group --group-name Step1-Access --description "Step-1 security group for SSH access" --vpc-id $VPC_ID
SGROUP_ID=$(aws ec2 describe-security-groups --filters Name=description,Values="Step-1 security group for SSH access" | egrep "GroupId" | cut -f2 -d : | tr -d \",)
aws ec2 authorize-security-group-ingress --group-id $SGROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SGROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 wait security-group-exists --group-ids $SGROUP_ID
echo "Security group: Step1-Access $SGROUP_ID created"

# Create an ec2 instance running Ubuntu 18 AMI on t1.micro
INSTANCE_ID=$(aws ec2 run-instances --image-id ami-085925f297f89fce1 --count 1 --instance-type t1.micro --key-name Step1KeyPair --security-group-ids $SGROUP_ID --subnet-id $SUBNET_ID  | egrep "InstanceId" | cut -f2 -d : | tr -d \",)
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value="Step-1"
echo "$INSTANCE_ID created. Booting up"
aws ec2 wait instance-exists --instance-ids $INSTANCE_ID
PUB_IPADDRESS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | egrep "PublicIpAddress" | cut -f2 -d : | tr -d \",)
echo "Success! EC2 Instance $INSTANCE_ID created with public IP address: $PUB_IPADDRESS"
