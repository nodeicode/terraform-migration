# General purpose role for EC2 instances
resource "aws_iam_role" "ec2_app_role" {
  name = "ec2-app-role-kuali"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "EC2-App-Role-kuali"
  }
}

# Policy for CloudWatch Agent (if you install it on your AMI)
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# You might attach other policies if your application needs to interact with other AWS services (e.g., S3)
# resource "aws_iam_role_policy_attachment" "s3_access_policy" {
#   role       = aws_iam_role.ec2_app_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # Example
# }

resource "aws_iam_instance_profile" "ec2_app_instance_profile" {
  name = "ec2-app-instance-profile-kuali"
  role = aws_iam_role.ec2_app_role.name
}
