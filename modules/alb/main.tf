data "aws_vpc" "alb_vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "allow traffic to the ALB"
  vpc_id      = var.vpc_id
  tags = {
    Terraform-Project = "baseline"
  }
  ingress {
    description = "allow traffic from the internet to the ALB on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow traffic from the internet to the ALB on port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow traffic from the ALB to the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.alb_vpc.cidr_block]
  }
}

resource "aws_lb" "default" {
  name                       = var.name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
}

resource "aws_lb_listener" "http2https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.default_ssl_certificate_arn
  default_action {
    type = "redirect"
    redirect {
      host        = var.default_redirection_fqdn
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}