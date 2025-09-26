# ALB Security Group: Allows HTTP/HTTPS from the internet
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS to ALB"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "Kuali-ALB-SG" }
}

# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-host-sg"
  description = "Allow SSH to Bastion Host from Admin IP"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "SSH from Admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_for_bastion] 
  }
  egress { # Allow bastion to connect to private instances on SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] 
  }
  tags = { Name = "Bastion-Host-SG" }
}

# EC2 Instance Security Group: Allows traffic from ALB and SSH from Bastion
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-app-sg"
  description = "Allow traffic from ALB and SSH from Bastion"
  vpc_id      = aws_vpc.main.id
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    description     = "SSH from Bastion Host SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # Allow SSH from Bastion
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "Kuali-EC2-App-SG" }
}

# RDS Security Group: Allows MySQL traffic from EC2 instances
resource "aws_security_group" "rds_sg" {
  name        = "rds-db-sg"
  description = "Allow MySQL traffic from EC2 App SG"
  vpc_id      = aws_vpc.main.id
  ingress {
    description     = "MySQL from EC2 App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "Kuali-RDS-DB-SG" }
}
