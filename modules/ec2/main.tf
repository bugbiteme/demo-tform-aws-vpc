locals {
  tags = {
    Name        = "EC2Test"
    Product     = "Test"
    Engineer    = "Richard Tan"
    Org         = "URW"
    BU          = "US Systems"
    AppName     = "Ansible Testing"
    Environment = "Wit Sandbox"
  }
}



// Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = "ami-0721c9af7b9b75114"  # data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]

  tags = merge(local.tags,{
    "Name"      = "${var.namespace}-EC2-PUBLIC"
    "Terraform" = "true"
  })

  # Copies the ssh key file to home dir
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
  
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }

  }

}

/*
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
}


data "template_file" "win1" {
  template = <<EOF
  <powershell>
  $IP = "10.0.101.61"
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$Gateway = "10.0.101.1"
$Dns = "8.8.8.8","8.8.4.4"
$IPType = "IPv4"
# Retrieve the network adapter that you want to configure
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
# Remove any existing IP, gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
 $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}
If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
 $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}
 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
 -AddressFamily $IPType `
 -IPAddress $IP `
 -PrefixLength $MaskBits `
 -DefaultGateway $Gateway
# Configure the DNS client server IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS
  </powershell>
<persist>false</persist>
EOF
}


resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.windows.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  user_data_base64            = base64encode(data.template_file.win1.rendered)
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  private_ip                  = "10.0.101.61"

  tags = merge(local.tags,{
    "Name"      = "${var.namespace}-EC2-PUBLIC"
    "Terraform" = "true"
  })


  # Copies the ssh key file to home dir
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
  
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }

  }

}
*/

/*
// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private" {
  ami                         = "ami-0721c9af7b9b75114" #data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[1]
  vpc_security_group_ids      = [var.sg_priv_id]

  tags = merge(local.tags,{
    "Name"      = "${var.namespace}-EC2-PRIVATE"
    "Terraform" = "true"
  })

}
*/


// Userdata for resolv.conf and hostname update
data "template_file" "ora" {
  template = <<-EOT
  #cloud-config

mounts:
  - [ xvdc, none, swap, sw, 0, 0 ]

bootcmd:
  - mkswap /dev/xvdc
  - swapon /dev/xvdc
 

runcmd:
  ## Setup networks
  - nmcli con down 'System eth0'
  - nmcli con mod 'System eth0'
    ipv4.method "manual"
    ipv4.address "10.0.2.160/24"
    ipv4.gateway "10.0.2.1"
    ipv4.dns "8.8.8.8, 8.8.4.4"
    ipv4.dns-search "ad.us.westfield.com"
  - nmcli con up 'System eth0'
  - hostnamectl set-hostname USDTC2DXORDB1
  - mkdir  -p /app/xvdb
  - mkfs -t ext4  /dev/xvdb
  - echo "/dev/xvdb       /app   ext4    defaults,nofail 0       2" >> /etc/fstab
  - mount -a
  - yum update -y
  - systemctl mask cloud-init-local cloud-init cloud-config cloud-final
  EOT
  }



// Configure the Oracle EC2 instance in a private subnet
resource "aws_instance" "ora_private" {
  ami                         = "ami-036e9ca2e237025e5"
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  user_data_base64            = base64encode(data.template_file.ora.rendered)
  subnet_id                   = var.vpc.private_subnets[1]
  vpc_security_group_ids      = [var.sg_priv_id]
  private_ip                  = "10.0.2.160"


root_block_device {
    volume_type           = "gp2"
    encrypted             = true
    volume_size           = "10"
    delete_on_termination = "true"

    tags = {
    "Name"    = "USDTC2DXORDB1"
    "Volume"  = "Root Volume"
  }
  }

   // Add EBS Volume to Oracle instance
 ebs_block_device {
  device_name             = "/dev/xvdb"
  volume_size             = 20
  volume_type             = "gp2" # Can't control iops and throughput
  encrypted               = true
  ### Use below if you want higher performance volumes
#  volume_type = "gp3"
#  iops        = 3000 # Min is 3000. Max is 16000.
#  throughput  = 125 # This is the min. Max is 1000.
  delete_on_termination   = true

  tags = {
    "Name"    = "USDTC2DXORDB1"
    "Volume"  = "Data Volume"
  }
 }


   // Add EBS Volume to Oracle instance
 ebs_block_device {
  device_name             = "/dev/xvdc"
  volume_size             = 4
  volume_type             = "gp2" # Can't control iops and throughput
  encrypted               = true
  ### Use below if you want higher performance volumes
#  volume_type = "gp3"
#  iops        = 3000 # Min is 3000. Max is 16000.
#  throughput  = 125 # This is the min. Max is 1000.
  delete_on_termination   = true

  tags = {
    "Name"    = "USDTC2DXORDB1"
    "Volume"  = "Swap Volume"
  }
 }

 
  tags = merge(local.tags,{
    #"Name"      = "${var.namespace}-ORA-PRIVATE"
    "Name"      = "USDTC2DXORDB1" 
    "Terraform" = "true"
  })


}



/*
// Userdata for resolv.conf and hostname update
data "template_file" "ora2" {
  template = <<-EOT
  #cloud-config
runcmd:
  ## Setup networks
  - nmcli con down 'System eth0'
  - nmcli con mod 'System eth0'
    ipv4.method "manual"
    ipv4.address "10.0.2.161/24"
    ipv4.gateway "10.0.2.1"
    ipv4.dns "8.8.8.8, 8.8.4.4"
    ipv4.dns-search "ad.us.westfield.com"
  - nmcli con up 'System eth0'
  - hostnamectl set-hostname USDTC2DXORDB2
  - systemctl mask cloud-init-local cloud-init cloud-config cloud-final
  EOT
  }
  



 // Configure the Oracle EC2 instance in a private subnet 
resource "aws_instance" "ora2_private" {
  ami                         = "ami-0bf3b3e2db4302789"  # oracle 7.9 image
  #ami                         = "ami-0721c9af7b9b75114"
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  user_data_base64            = base64encode(data.template_file.ora2.rendered)
  subnet_id                   = var.vpc.private_subnets[1]
  vpc_security_group_ids      = [var.sg_priv_id]
  private_ip                  = "10.0.2.161"

root_block_device {
    volume_type           = "gp2"
    encrypted             = true
    volume_size           = "10"
    delete_on_termination = "true"
  }


 
  // Add EBS Volume to Oracle instance
 ebs_block_device {
  device_name = "/dev/xvdb"
  volume_size = 10
  volume_type = "gp2" # Can't control iops and throughput
  encrypted   = true
  ### Use below if you want higher performance volumes
#  volume_type = "gp3"
#  iops        = 3000 # Min is 3000. Max is 16000.
#  throughput  = 125 # This is the min. Max is 1000.
  delete_on_termination = false
 }

}

  tags = merge(local.tags,{
  #  "Name"      = "${var.namespace}-ORA2-PRIVATE"
    "Name"      = "USDTC2DXORDB2"
    "Terraform" = "true"
  })
*/