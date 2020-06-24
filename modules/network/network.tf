resource "aws_vpc" "cluster-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Cluster-VPC"
    IAC  = "Sandbox"
  }
}

resource "aws_internet_gateway" "cluster-igw" {
  vpc_id = aws_vpc.cluster-vpc.id

  tags = {
    Name = "Cluster-IGW"
    IAC  = "Sandbox"
  }
}


resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.cluster-vpc.id
  count  = length(var.availability_zone_names)

  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = var.availability_zone_names[count.index]

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
    IAC  = "Sandbox"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.cluster-vpc.id
  count  = length(var.availability_zone_names)

  cidr_block        = "10.0.${count.index + 1 + length(var.availability_zone_names)}.0/24"
  availability_zone = var.availability_zone_names[count.index]

  tags = {
    Name = "Public-Subnet-${count.index + 1}"
    IAC  = "Sandbox"
  }
}

resource "aws_eip" "cluster-ngw-eip" {
  vpc                       = true
  associate_with_private_ip = "10.0.${length(var.availability_zone_names) + 1}.5"
  depends_on                = [aws_internet_gateway.cluster-igw]

  tags = {
    Name = "Cluster-NATGW-EIP"
    IAC  = "Sandbox"
  }
}


resource "aws_nat_gateway" "cluster-natgw" {
  allocation_id = aws_eip.cluster-ngw-eip.id
  subnet_id     = element(aws_subnet.public-subnet, 0).id

  tags = {
    Name = "Cluster-NAT-Gateway"
    IAC  = "Sandbox"
  }
}


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster-igw.id
  }

  tags = {
    Name = "Public-Route-Table"
    IAC  = "Sandbox"
  }

}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.cluster-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cluster-natgw.id
  }
}

resource "aws_route_table_association" "public-rta" {
  count = length(aws_subnet.public-subnet)

  subnet_id      = element(aws_subnet.public-subnet, count.index).id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-rta" {
  count = length(aws_subnet.private-subnet)

  subnet_id      = element(aws_subnet.private-subnet, count.index).id
  route_table_id = aws_route_table.private-rt.id
}

# resource "aws_network_acl" "private-nacl" {
#   vpc_id = aws_vpc.cluster-vpc.id
#   subnet_ids = [for sn in aws_subnet.private-subnet : sn.id]

#   tags = {
#       Name = "Private-NACL"
#   }
# }
