terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_default_security_group" "default" {
  vpc_id = data.aws_vpc.selected.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["public*"]
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = data.aws_vpc.selected.id
  count                   = 3
  cidr_block              = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, count.index + length(data.aws_subnets.public.ids))
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-${count.index + 1}"
  }
}

## NAT Gateway & Route Tables

resource "aws_eip" "nat" {}

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = data.aws_subnets.public.ids[0]
#   tags = {
#     Name              = "nat"
#     Terraform-Project = "baseline"
#   }
# }

module "fck-nat" {
  source              = "RaJiska/fck-nat/aws"
  version             = "1.3.0"
  name                = "fck-nat"
  vpc_id              = data.aws_vpc.selected.id
  subnet_id           = data.aws_subnets.public.ids[0]
  ha_mode             = false
  eip_allocation_ids  = [aws_eip.nat.id]
  update_route_tables = false
}

resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "private"
  }
  route {
    cidr_block = data.aws_vpc.selected.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = module.fck-nat.eni_id
  }

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_nat_gateway.nat.id
  # }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

