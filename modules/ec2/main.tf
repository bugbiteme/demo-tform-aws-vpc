resource "aws_instance" "ec2_public" {
  ami                         = "ami-0915bcb5fa77e4892"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]

  tags = {
    "Name" = "${var.namespace}-EC2-PUBLIC"
  }

  # Copies the sshkey file to home dir
  # TODO fix chmod issue (need to "chmod 400 before you can use")
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "/home/ec2-user/${var.key_name}.pem"


    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
  
}

resource "aws_instance" "ec2_private" {
  ami                         = "ami-0915bcb5fa77e4892"
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[1]
  vpc_security_group_ids      = [var.sg_priv_id]

  tags = {
    "Name" = "${var.namespace}-EC2-PRIVATE"
  }

}