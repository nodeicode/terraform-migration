variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (2 AZs)"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (2 AZs)"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

variable "availability_zones" {
  description = "Availability zones to use (2 AZs)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] # Adjust to your region
}

variable "db_username" {
  description = "RDS Master Username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS Master Password"
  type        = string
  default     = "" # CHANGE THIS FOR ACTUAL DEPLOYMENTS
  sensitive   = true
}

variable "custom_ami_id" {
  description = "Custom AMI ID for EC2 instances (populated after manual AMI creation)"
  type        = string
  default     = ""
}

variable "ec2_key_pair_name" {
  description = "Name of the EC2 Key Pair to use for SSH access to instances (including bastion)"
  type        = string
  # Ensure you have an EC2 Key Pair with this name in your AWS account in the target region
  default     = "your-ec2-key-pair" # REPLACE with your actual key pair name
}

variable "admin_ip_for_bastion" {
  description = "Your trusted IP address for SSH access to the bastion host (CIDR format)"
  type        = string
  default     = "0.0.0.0/0"
}
