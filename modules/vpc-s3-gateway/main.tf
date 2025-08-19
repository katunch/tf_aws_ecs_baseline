data "aws_region" "current" {}


resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.route_table_ids

  tags = {
    Name = "${var.name}"
  }
}

# Security group for the CloudWatch VPC endpoint
resource "aws_security_group" "endpoint_sg" {
  name        = "${var.name}-sg"
  description = "Allow HTTPS traffic to S3 endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}