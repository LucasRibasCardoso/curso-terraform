resource "aws_subnet" "public" {
  for_each = var.availability_zones

  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.value.netnum)
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = var.availability_zones

  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, each.value.netnum + 10) # Ex: 10.0.10.0/24
  availability_zone = each.value.az

  tags = {
    Name = "${var.project_name}-private-${each.key}"
    Tier = "private"
  }
}

resource "aws_route_table_association" "public" {
  for_each = var.availability_zones

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = var.availability_zones

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}