#!/usr/bin/env bash

# Connects to Step-1 ec2 instance via ssh and gets Django up and running

# Check that Step-1 instance is running and get public ip address
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Step-1" | egrep "InstanceId" | cut -f2 -d : | tr -d \", | cut -d ' ' -f2)
PUB_IPADDRESS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | egrep "PublicIpAddress" | cut -f2 -d : | tr -d \", | cut -d ' ' -f2)
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Connecting to $INSTANCE_ID at $PUB_IPADDRESS"

ssh -o "StrictHostKeyChecking no" -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo apt-get update
echo "ssh connection made, now provisioning with python3 and django"
ssh -o "StrictHostKeyChecking yes" -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo apt-get install -y python3-pip
ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo pip3 install django
# set python3 as default python.
ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
# verify with: python -m django --version
echo "Django and Python3 installed"


ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS django-admin startproject mysite
# Modify ./mysite/mysite/settings.py
ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sed -i "28s:[[]:\[\'\*\':" ./mysite/mysite/settings.py
# check if it worked with:
ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS cat ./mysite/mysite/settings.py | egrep "ALLOWED_HOSTS"

# Runserver
ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS "cd ./mysite ; sudo screen -dmS django-screen python manage.py runserver 0:80"
echo "Django runserver on at $PUB_IPADDRESS"

# To turn off the screen:
# ssh -i Step1KeyPair.pem ubuntu@$PUB_IPADDRESS sudo screen -XS django-screen quit