output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "rds_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.default.endpoint
}

output "custom_ami_id_used" {
  description = "The Custom AMI ID used for the EC2 instances in the Auto Scaling Group"
  value       = var.custom_ami_id
}

output "route53_hosted_zone_id" {
  description = "The ID of the Route 53 Hosted Zone"
  value       = aws_route53_zone.main.zone_id
}

output "route53_name_servers" {
  description = "Name servers for the Route 53 Hosted Zone (to be configured at your domain registrar)"
  value       = aws_route53_zone.main.name_servers
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "s3_assets_bucket_name" {
  description = "The name of the S3 bucket for static assets"
  value       = aws_s3_bucket.assets.bucket
}

output "waf_acl_arn" {
  description = "The ARN of the WAFv2 Web ACL (regional for ALB)"
  value       = aws_wafv2_web_acl.main.arn
}

output "application_url_https" {
  description = "The HTTPS URL to access the application via CloudFront"
  value       = "https://${aws_route53_zone.main.name}"
}

output "bastion_host_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = aws_eip.bastion_eip.public_ip
}

output "ec2_app_instance_profile_name" {
  description = "The name of the IAM instance profile for EC2 app instances"
  value       = aws_iam_instance_profile.ec2_app_instance_profile.name
}
