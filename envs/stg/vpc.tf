# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

# Public subnet
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[0]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[0]
  tags = {
    Name = "${var.env}-subnet-public-1a"
  }
}
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[1]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[1]
  tags = {
    Name = "${var.env}-subnet-public-1c"
  }
}

# IGW
resource "aws_internet_gateway" "stg" {
  vpc_id = aws_vpc.this.id
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
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
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_app_subnets[0]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[0]
  tags = {
    Name = "${var.env}-subnet-private-app-1a"
  }
}
resource "aws_subnet" "private_app_1c" {
  vpc_id                  = aws_vpc.this.id
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
  vpc_id = aws_vpc.this.id
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
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_db_subnets[0]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[0]
  tags = {
    Name = "${var.env}-subnet-private-db-1a"
  }
}
resource "aws_subnet" "private_db_1c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_db_subnets[1]
  map_public_ip_on_launch = false
  availability_zone       = var.azs[1]
  tags = {
    Name = "${var.env}-subnet-private-db-1c"
  }
}

# VPC peering
# https://qiita.com/MSHR-Dec/items/a604c4934595334dfb2a
data "aws_vpc" "second_account" {
  provider = aws.second_account

  filter {
    name   = "tag:Name"
    values = ["second-account-vpc"]
  }
}
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = data.aws_vpc.second_account.id
  vpc_id        = aws_vpc.this.id
  peer_owner_id = data.aws_caller_identity.second_account.account_id
  auto_accept   = false
  tags = {
    Name = "second-account"
    Side = "Requester"
  }
}
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  provider                  = aws.second_account
  auto_accept               = true

  tags = {
    Name = "second-account"
    Side = "Accepter"
  }
}
resource "aws_vpc_peering_connection_options" "requester" {
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
  requester {
    allow_remote_vpc_dns_resolution = true
  }
}
resource "aws_vpc_peering_connection_options" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
  provider                  = aws.second_account
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "peer_to_second_account" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.second_account.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

data "aws_route_table" "second_account" {
  provider = aws.second_account

  filter {
    name   = "tag:Name"
    values = ["second-account-route-table-private"]
  }
}
resource "aws_route" "second_account" {
  provider                  = aws.second_account
  route_table_id            = data.aws_route_table.second_account.id
  destination_cidr_block    = aws_vpc.this.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# DNS for peering vpc
data "aws_route53_zone" "second_account" {
  provider     = aws.second_account
  name         = "myapp-2nd.local"
  private_zone = true
}

resource "aws_route53_vpc_association_authorization" "assoc" {
  provider = aws.second_account
  vpc_id   = aws_vpc.this.id
  zone_id  = data.aws_route53_zone.second_account.id
}

resource "aws_route53_zone_association" "assoc" {
  vpc_id  = aws_route53_vpc_association_authorization.assoc.vpc_id
  zone_id = aws_route53_vpc_association_authorization.assoc.zone_id
}
