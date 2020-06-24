data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_vpc" "sandbox" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "Sandbox"
        IaC = "Sandbox"
    }
}

resource "aws_subnet" "public-a" {
    vpc_id = aws_vpc.sandbox.id
    cidr_block = "10.0.0.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        Name = "Sandbox-Public-A"
        IaC = "Sandbox"
    }
}

resource "aws_subnet" "private-a" {
    vpc_id = aws_vpc.sandbox.id
    cidr_block = "10.0.1.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        Name = "Sandbox-Private-A"
        IaC = "Sandbox"
    }
}

resource "aws_subnet" "public-b" {
    vpc_id = aws_vpc.sandbox.id
    cidr_block = "10.0.2.0/24"
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
        Name = "Sandbox-Public-B"
        IaC = "Sandbox"
    }
}

resource "aws_subnet" "private-b" {
    vpc_id = aws_vpc.sandbox.id
    cidr_block = "10.0.3.0/24"
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
        Name = "Sandbox-Private-B"
        IaC = "Sandbox"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.sandbox.id

    tags = {
        Name = "Sandbox-Public"
        IaC = "Sandbox"
    }
}

resource "aws_route_table" "private-a" {
    vpc_id = aws_vpc.sandbox.id

    tags = {
        Name = "Sandbox-Private-A"
        IaC = "Sandbox"
    }
}

resource "aws_route_table" "private-b" {
    vpc_id = aws_vpc.sandbox.id

    tags = {
        Name = "Sandbox-Private-B"
        IaC = "Sandbox"
    }
}

resource "aws_route_table_association" "public-a" {
    subnet_id = aws_subnet.public-a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
    subnet_id = aws_subnet.public-b.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-a" {
    subnet_id = aws_subnet.private-a.id
    route_table_id = aws_route_table.private-a.id
}

resource "aws_route_table_association" "private-b" {
    subnet_id = aws_subnet.private-b.id
    route_table_id = aws_route_table.private-b.id
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.sandbox.id

    tags = {
        Name = "Sandbox-Internet-Gateway"
        IaC = "Sandbox"
    }
}

resource "aws_route" "igw-public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}