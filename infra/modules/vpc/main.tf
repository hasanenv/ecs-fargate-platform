resource "aws_vpc" "hk_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.hk_vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = local.tags
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.hk_vpc.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]

  tags = local.tags
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.hk_vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = local.tags
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.hk_vpc.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]

  tags = local.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hk_vpc.id

  tags = local.tags
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.hk_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_eip" "natgw" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = local.tags
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.allocation_id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = local.tags
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.hk_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rtb.id
}
