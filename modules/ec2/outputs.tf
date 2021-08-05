
output "public_ip" {
  value = aws_instance.ec2_public.public_ip
}


output "private_ip" {
  value = aws_instance.ora_private.private_ip
}


/*
output "private_ip2" {
  value = aws_instance.ora2_private.private_ip
}
*/