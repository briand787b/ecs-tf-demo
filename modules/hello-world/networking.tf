data "aws_availability_zones" "available" {}

resource "aws_vpc" "hello-world-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "hello-world-vpc"
    IAC = "Hello World"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.hello-world-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "hello-world-public"
    IAC = "Hello World"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.hello-world-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "hello-world-private"
    IAC = "Hello World"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.hello-world-vpc.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.hello-world-vpc.id
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hello-world-vpc.id
}

resource "aws_nat_gateway" "ngw" {
  subnet_id = aws_subnet.public.id
  allocation_id = aws_eip.nat.id

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route" "public_igw" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.ngw.id
}

resource "aws_security_group" "http" {
  name = "http"
  description = "HTTP Traffic"
  vpc_id = aws_vpc.hello-world-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https" {
  name = "https"
  description = "HTTPS Traffic"
  vpc_id = aws_vpc.hello-world-vpc.id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress-all" {
  name = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id = aws_vpc.hello-world-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hello-world-ingress" {
  name = "api_ingress"
  description = "Allow ingress to API"
  vpc_id = aws_vpc.hello-world-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc_id" {
  value = aws_vpc.hello-world-vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}