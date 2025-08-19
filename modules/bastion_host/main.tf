data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "ssh" {
  name        = var.name
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ssh_ingress" {
  security_group_id = aws_security_group.ssh.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jumphost-vpc-access" {
  security_group_id = aws_security_group.ssh.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_key_pair" "tapmanagement-jumphost" {
  key_name   = "${var.name}-key"
  public_key = var.public_key
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.name}-profile"
  role = aws_iam_role.ec2_instance_role.name
}

data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}

resource "aws_instance" "jumphost" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.tapmanagement-jumphost.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.tftpl", {
    users                = var.additional_ssh_users
    additional_user_data = var.additional_user_data
  })
  user_data_replace_on_change = true

  root_block_device {
    encrypted  = true
    kms_key_id = data.aws_kms_alias.ebs.target_key_arn
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    "Name" = var.name
  }
}

resource "aws_route53_record" "jumphost" {
  zone_id = var.route53_zone_id
  name    = var.fqdn
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.jumphost.public_dns]
}