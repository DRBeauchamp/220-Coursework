The bash scripts in this repo use the AWS CLI (2) to create a new (free tier eligible) VPC and associated resources in the us-east-1 region to host an ec2 instance running Ubuntu 18; then provisions and runs the Django default page on it's public ip.

Prerequisites:
    An AWS account
    AWS CLI version 2

  create-step-1.sh - creates a VPC, with a public subnet, associated resources and a single ec2 instance running Ubuntu 18.

  create-step-2.sh - ssh to that instance and gets Django installed and running the default "hello world" page at it's ip address.

  delete.sh - Cleans up and deletes all of the resources created in the first two scripts.
