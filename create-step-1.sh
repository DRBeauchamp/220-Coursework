#!/usr/bin/env bash

aws ec2 create-vpc --cidr-block 10.0.0.0/16
VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[-1]' | egrep "VpcId" | cut -f2 -d : | tr -d \",)

aws ec2 create-internet-gateway
IGW_ID=$(aws ec2 describe-internet-gateways | egrep "igw-" | cut -f2 -d : | tr -d \",)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

aws ec2 create-subnet --cidr-block 10.0.1.0/24 --vpc-id $VPC_ID
PUB_SNET_ID=$(aws ec2 describe-subnets | egrep "SubnetId" | tail -1 | cut -f2 -d : | tr -d \",)
aws ec2 modify-subnet-attribute --subnet-id $PUB_SNET_ID --map-public-ip-on-launch


# PROBLEM: If I create a private and public subnet, I don't know how to distinguish them for naming purposes so ignoring for now
# aws ec2 create-subnet --cidr-block 10.0.2.0/24 --vpc-id $VPC_ID
# PRV_SNET_ID=$(aws ec2 describe-subnets)


aws ec2 create-route-table --vpc-id $VPC_ID
PUB_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables | egrep "rtb-" | head -1 | cut -f2 -d : | tr -d \",)

aws ec2 create-route --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --route-table-id $PUB_ROUTE_TABLE_ID
aws ec2 associate-route-table --route-table-id $PUB_ROUTE_TABLE_ID --subnet-id $PUB_SNET_ID



# IGNORING Private Route Table for now
# aws ec2 create-route-table --vpc-id $VPC_ID
#PRV_ROUTE_TABLE_ID=$("rtb-0633889fa5521db14")

# aws ec2 allocate-address
#export EIP_ID="eipalloc-0fb8b611d30995791"

# aws ec2 create-nat-gateway --subnet-id $PUB_SNET_ID --allocation-id $EIP_ID
#export NAT_GW_ID="nat-0ed4204fb79add235"

# aws ec2 create-route --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW_ID --route-table-id $PRV_ROUTE_TABLE_ID
# aws ec2 associate-route-table --route-table-id $PRV_ROUTE_TABLE_ID --subnet-id $PRV_SNET_ID

echo "These resources were just created: "
echo $VPC_ID $IGW_ID $PUB_SNET_ID $PRV_SNET_ID $PUB_ROUTE_TABLE_ID $PRV_ROUTE_TABLE_ID $EIP_ID $NAT_GW_ID
