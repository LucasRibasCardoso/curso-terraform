output "vpc_id" {
  value = aws_vpc.terraform_vpc.id
}

output "subnet_pub_1a" {
  value = aws_subnet.public["az_1a"].id
}

output "subnet_pub_1b" {
  value = aws_subnet.public["az_1b"].id
}

output "subnet_priv_1a" {
  value = aws_subnet.private["az_1a"].id
}

output "subnet_priv_1b" {
  value = aws_subnet.private["az_1b"].id
}