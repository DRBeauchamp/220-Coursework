The scripts in this repository use AWS CLI to create a new (free tier eligible) vpc and associated resources, then an ec2 instance within that VPC running Ubuntu 18 in the us-east-1 region, then provisions and runs the Django default page on it's public ip.

Prerequisites: 
    An AWS account 
    AWS CLI version 2

  create-step-1.sh - creates a VPC, with a public subnet, associated resources and a single ec2 instance running Ubuntu 18.

  create-step-2.sh - connects to that instance and gets Django installed and running the default "hello world" page at it's ip address.

  delete.sh - deletes all of the resources created in the first two scripts.
