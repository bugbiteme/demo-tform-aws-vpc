output "vpc" {
  value = module.vpc
}

output "sg_id" {
    value = aws_security_group.allow_ssh.id
}