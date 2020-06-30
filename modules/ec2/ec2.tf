data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion-host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "brian-ubuntu"
  vpc_security_group_ids = [ var.sg_id ]
  subnet_id = var.public_subnet_ids[0]
  associate_public_ip_address = true

  tags = {
    IaC = "Sandbox"
    Name = "Bastion-Host"
  }
}

resource "aws_instance" "private-host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "brian-ubuntu"
  vpc_security_group_ids = [ var.sg_id ]
  subnet_id = var.private_subnet_ids[0]
  associate_public_ip_address = false

  tags = {
    IaC = "Sandbox"
    Name = "Private-Host"
  }
}