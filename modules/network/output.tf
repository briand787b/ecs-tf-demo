output "public_subnets" {
  value = "${aws_subnet.public-subnet}"
}
    
output "private_subnets" {
  value = "${aws_subnet.private-subnet}"
}

output "vpc_id" {
  value = "${aws_vpc.cluster-vpc.id}"
}
