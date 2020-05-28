#!/usr/bin/env bash

# Connects to Step-1 ec2 instance via ssh and gets the “hello world” default Django page up and running at public IP address
export AWS_DEFAULT_REGION=us-east-1

# Check that Step-1 instance is running and get ip address
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Step-1" "Name=instance-state-name,Values=pending,running" | grep InstanceId | cut -f4 -d \" )
PUB_IPADDRESS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | grep PublicIpAddress | cut -f4 -d \" )

echo "Checking that Step-1 instance is running, This could take a few minutes..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
echo -e "It is running now.\nConnecting to $INSTANCE_ID at $PUB_IPADDRESS"

ssh -o "StrictHostKeyChecking no" -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo apt-get update &> ./.install.log
echo "SSH connection made, now provisioning with python3 and django. Please wait..."
ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo apt-get install -y python3-pip >> ./.install.log 2>&1
ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo pip3 install django >> ./.install.log 2>&1
# set python3 as default python.
ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
# can verify with: python -m django --version
echo "Django and Python3 installed"

# ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS django-admin startproject mysite
# Modify ./mysite/mysite/settings.py
# ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sed -i "28s:[[]:\[\'\*\':" ./mysite/mysite/settings.py
# check if it worked with:
# ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS cat ./mysite/mysite/settings.py | egrep "ALLOWED_HOSTS"

# Runserver as root via screen
# ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS "cd ./mysite ; sudo screen -dmS django-screen python manage.py runserver 0:80"
# echo "Django runserver on at $PUB_IPADDRESS"

# To turn off the screen:
# ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo screen -XS django-screen quit
