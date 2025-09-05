terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6"
    }
  }
}

## -------------------------
## Providers
## -------------------------
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

## ---------------------
## VPC & Networking
## ---------------------
data "aws_vpc" "default" {
  default = true
}

module "vpc" {
  source = "./modules/vpc"
  vpc_id = data.aws_vpc.default.id
}

module "vpc_s3_gateway" {
  source          = "./Modules/vpc-s3-gateway"
  name            = "s3-gateway"
  vpc_id          = data.aws_vpc.default.id
  vpc_cidr_block  = data.aws_vpc.default.cidr_block
  route_table_ids = module.vpc.private_route_table_ids
}

module "bastion" {
  source          = "./modules/bastion_host"
  name            = "bastion-host"
  vpc_id          = data.aws_vpc.default.id
  public_key      = var.bastion_default_public_key
  route53_zone_id = var.route53_zone_id
  fqdn            = "bastion.${var.fqdn}"
  subnet_id       = module.vpc.public_subnet_ids[0]
}

module "regional_certificate" {
  source           = "./modules/acm-certificate"
  route53_zone_id  = var.route53_zone_id
  fqdn             = var.fqdn
  additional_fqdns = []
}

module "us-east-1_certificate" {
  source = "./modules/acm-certificate"
  providers = {
    aws = aws.us-east-1
  }
  route53_zone_id  = var.route53_zone_id
  fqdn             = var.fqdn
  additional_fqdns = []
}

module "alb" {
  source                      = "./modules/alb"
  vpc_id                      = data.aws_vpc.default.id
  public_subnet_ids           = module.vpc.public_subnet_ids
  default_ssl_certificate_arn = module.regional_certificate.arn
  default_redirection_fqdn    = "software-brauerei.ch"
}

module "internet_access_security_group" {
  source      = "./modules/vpc_security_group"
  name        = "internet-access-sg"
  description = "Security group for internet access"
  vpc_id      = data.aws_vpc.default.id
  ingress_rules = [
    {
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = data.aws_vpc.default.cidr_block
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}

## ---------------------
## ECS Cluster
## ---------------------
module "ecs_clusters" {
  for_each = var.ecs_clusters
  source       = "./modules/ecs"
  cluster_name = each.key
}
