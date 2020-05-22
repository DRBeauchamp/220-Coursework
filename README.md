The scripts in this repository create a new AWS (free tier eligible) ec2 instance from scratch, then provisions and runs the Django default page on it's public ip.

  create-step-1.sh creates a VPC, with a public subnet, and a single ec2 instance.

  create-step-2.sh connects to that instance and gets Django installed and running the default "hello world" page at it's ip.

  delete.sh deletes all of the resources created in the first two scripts.
