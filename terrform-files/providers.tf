# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify a version constraint
    }
  }
}

# Provider alias for ACM certificate in us-east-1 (for CloudFront)
provider "aws" {
  alias  = "us_east_1_acm"
  region = "us-east-1"
}