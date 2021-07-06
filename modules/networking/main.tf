
// TODO break public and private into separate AZs
data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name                             = "${var.namespace}-vpc"
  cidr                             = "10.0.0.0/16"
  azs                              = data.aws_availability_zones.available.names
  private_subnets                  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets                   = ["10.0.101.0/24", "10.0.102.0/24"]
  #assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  enable_dhcp_options              = true
  enable_nat_gateway               = false
  single_nat_gateway               = true

  tags = {
    Terraform = "true"
  }
}


// SG to allow SSH connections from Richard's Home
resource "aws_security_group" "allow_ssh_pub" {
  name        = "${var.namespace}-allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH for rtan home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["173.196.226.234/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.namespace}-allow_ssh_pub"
    Terraform = "true"
  }
}

// SG to onlly allow SSH connections from VPC public subnets
resource "aws_security_group" "allow_ssh_priv" {
  name        = "${var.namespace}-allow_ssh_priv"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH only from internal VPC clients"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.namespace}-allow_ssh_priv"
    Terraform = "true"
  }
}