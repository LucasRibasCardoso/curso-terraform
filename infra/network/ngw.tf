resource "aws_eip" "ngw" {
  for_each = var.availability_zones

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-ngw-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "ngw" {
  for_each = var.availability_zones

  allocation_id = aws_eip.ngw[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${var.project_name}-ngw-${each.key}"
  }

  depends_on = [aws_internet_gateway.igw]
}
