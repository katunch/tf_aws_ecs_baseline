# AWS ECS Baseline Infrastructure

This Terraform module provides a comprehensive baseline infrastructure setup for AWS ECS (Elastic Container Service) deployments. It creates a production-ready environment with networking, security, load balancing, and container orchestration capabilities.

## Overview

This module establishes a complete AWS infrastructure foundation that includes:

- **VPC and Networking**: Private subnets with NAT gateway (using [fck-nat](https://fck-nat.dev/stable/)) for secure container networking
- **ECS Clusters**: Fargate-based container clusters with Container Insights enabled
- **Application Load Balancer**: SSL-terminated load balancer with automatic HTTP to HTTPS redirection
- **Security Groups**: Properly configured security groups for internet access and VPC isolation
- **SSL Certificates**: ACM certificates for both regional and CloudFront (us-east-1) usage
- **Bastion Host**: Secure SSH access point for administrative tasks
- **S3 VPC Gateway**: Cost-effective S3 access from private subnets

## Architecture

The module uses the default VPC and creates:

1. **Private Subnets**: Three private subnets across availability zones for ECS tasks
2. **NAT Gateway**: Cost-effective [fck-nat](https://fck-nat.dev/stable/) solution for outbound internet access
3. **ECS Clusters**: Fargate-enabled clusters with spot instance support for cost optimization
4. **Load Balancer**: Internet-facing ALB with SSL termination and security headers
5. **Route 53 Integration**: DNS management for certificates and bastion host

## Key Features

- **Cost Optimized**: Uses Fargate Spot instances and fck-nat for reduced costs
- **Security Focused**: Private subnets, proper security groups, and SSL enforcement
- **High Availability**: Multi-AZ deployment with automatic failover
- **Container Insights**: Enhanced monitoring and observability for ECS clusters
- **SSL/TLS**: Automated certificate management with ACM
- **Bastion Access**: Secure administrative access to private resources

## Usage

```hcl
module "ecs_baseline" {
  source = "."
  
  aws_region                   = "eu-central-1"
  route53_zone_id             = "Z1234567890ABC"
  fqdn                        = "example.com"
  bastion_default_public_key  = "ssh-rsa AAAAB3NzaC1yc2E..."
  
  ecs_clusters = {
    "production" = {}
    "staging"    = {}
  }
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `aws_region` | The AWS region where resources will be created | `string` | `"eu-central-1"` |
| `route53_zone_id` | The Route 53 zone ID for DNS management | `string` | Required |
| `fqdn` | The fully qualified domain name for certificates | `string` | Required |
| `bastion_default_public_key` | SSH public key for bastion host access | `string` | Required |
| `ecs_clusters` | Map of ECS cluster names to create | `map(object({}))` | Required |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `ecs_clusters` | List of created ECS clusters with names and ARNs |
| `lb_dns_name` | DNS name of the Application Load Balancer |
| `lb_https_listener_arn` | ARN of the HTTPS listener for routing rules |
| `vpc_public_subnet_ids` | IDs of public subnets |
| `vpc_private_subnet_ids` | IDs of private subnets for ECS tasks |
| `vpc_internet_access_security_group_id` | Security group ID for internet access |

## Modules

This baseline infrastructure consists of several sub-modules:

- **vpc**: Creates private subnets and NAT gateway configuration
- **ecs**: Manages ECS clusters with Fargate capacity providers
- **alb**: Application Load Balancer with SSL termination
- **acm-certificate**: SSL certificate management for multiple regions
- **bastion_host**: Secure administrative access
- **vpc_security_group**: Security group management
- **vpc-s3-gateway**: VPC endpoint for S3 access

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 6.9
- Valid Route 53 hosted zone
- SSH key pair for bastion access

## Security Considerations

- ECS tasks run in private subnets with no direct internet access
- All HTTP traffic is automatically redirected to HTTPS
- Security groups follow least privilege principles
- Bastion host provides controlled administrative access
- VPC endpoints reduce data transfer costs and improve security

## Cost Optimization

- Fargate Spot instances used by default (50% weight)
- [fck-nat](https://fck-nat.dev/stable/) instead of managed NAT gateway
- S3 VPC gateway endpoint for free S3 access
- Regional certificate replication only when needed