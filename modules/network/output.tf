output "private_subnet_ids" {
    value = [
        aws_subnet.private-a.id,
        aws_subnet.private-b.id,
    ]
}

output "public_subnet_ids" {
    value = [
        aws_subnet.public-a.id,
        aws_subnet.public-b.id,
    ]
}

output "vpc_id" {
    value = aws_vpc.sandbox.id
}

output "allow_all_sg_id" {
    value = aws_security_group.allow_all.id
}

output "igw" {
    value = aws_internet_gateway.igw
}