resource "aws_instance" "example" {
    ami                          = "ami-0915bcb5fa77e4892"
    associate_public_ip_address  = true
    instance_type                = "t2.micro"
    key_name                     = var.key_name
    subnet_id                    = var.vpc.public_subnets[0]
    vpc_security_group_ids       = [var.sg_id]

    tags                         = {
        "Name" = "${var.namespace}-EC2-PUBLIC"
    }

}