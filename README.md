# Amazon Resources Created Using Terraform
Work in progress... documentation coming! Stay tuned!!

## Current state

Modules:

- ssh-key: Generates an ssh key pair
- network: Sets up a VPC with IGWs, NAT GWs, 2 public subnets, 2 private subnets, SG to SSH in from anywhere
- ec2: Currently creates a single ec2 instance in a public subnet (TODO: add one in private subnet)