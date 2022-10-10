# VPC
resource "aws_vpc" "stg" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

# Public subnet
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.stg.id
  cidr_block              = var.public_subnets[0]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[0]
  tags = {
    Name = "${var.env}-subnet-public-1a"
  }
}
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.stg.id
  cidr_block              = var.public_subnets[1]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[1]
  tags = {
    Name = "${var.env}-subnet-public-1c"
  }
}

# IGW
resource "aws_internet_gateway" "stg" {
  vpc_id = aws_vpc.stg.id
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.stg.id
  tags = {
    Name = "${var.env}-route-table-public"
  }
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.stg.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# Private subnet for application
resource "aws_subnet" "private_app_1a" {
  vpc_id                  = aws_vpc.stg.id
  cidr_block              = var.private_app_subnets[0]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[0]
  tags = {
    Name = "${var.env}-subnet-private-app-1a"
  }
}
resource "aws_subnet" "private_app_1c" {
  vpc_id                  = aws_vpc.stg.id
  cidr_block              = var.private_app_subnets[1]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[1]
  tags = {
    Name = "${var.env}-subnet-private-app-1c"
  }
}

# NAT (public_1aのみ)
resource "aws_eip" "nat_gateway" {
  vpc        = true
  depends_on = [aws_internet_gateway.stg]
  tags = {
    Name = "${var.env}-subnet-public-1a"
  }
}
resource "aws_nat_gateway" "stg_1" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_1a.id
  depends_on    = [aws_internet_gateway.stg]
  tags = {
    Name = "${var.env}-subnet-public-1a"
  }
}

# Route table for private subnets (Natが1つの場合、Route tableも1つ)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.stg.id
  tags = {
    Name = "${var.env}-route-table-private"
  }
}
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.stg_1.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_app_1a.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_app_1c.id
  route_table_id = aws_route_table.private.id
}

# Private subnet for DB
resource "aws_subnet" "private_db_1a" {
  vpc_id                  = aws_vpc.stg.id
  cidr_block              = var.private_db_subnets[0]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[0]
  tags = {
    Name = "${var.env}-subnet-private-db-1a"
  }
}
resource "aws_subnet" "private_db_1c" {
  vpc_id                  = aws_vpc.stg.id
  cidr_block              = var.private_db_subnets[1]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[1]
  tags = {
    Name = "${var.env}-subnet-private-db-1c"
  }
}
