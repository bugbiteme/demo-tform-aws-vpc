# Amazon Resources Created Using Terraform
Work in progress... documentation coming! Stay tuned!!

## Current state

Modules:

- ssh-key: Generates an ssh key pair
- network: Sets up a VPC with IGWs, NAT GWs, 2 public subnets, 2 private subnets, SG to SSH in from anywhere
- ec2: Currently creates a bastian ec2 instance in a public subnet and a ec2 instance in a private subnet
- each subnet is in a different AZ
- private key is copied over to the bastion ec2 instance so it can ssh into the private subnet
- ec2 in private subnet has outgoing network access though the NAT gateway
- may add ansible playbook to take care of copying over the shh key to the bastian ec2