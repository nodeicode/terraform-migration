resource "aws_lb" "main" {
  name               = "kuali-alb-2az"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = false
  tags = { Name = "Kuali-ALB-2AZ" }
}

resource "aws_lb_target_group" "main" {
  name        = "kuali-tg-2az"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
  tags = { Name = "Kuali-TG-2AZ" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
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
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn # From acm_route53_waf.tf
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_launch_template" "main" {
  name_prefix            = "kuali-lt-2az-"
  image_id               = var.custom_ami_id
  instance_type          = "t2.micro"
  key_name               = var.ec2_key_pair_name # Added for SSH access
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_app_instance_profile.name # Using generic app role
  }

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "Kuali-WebServer-2AZ" }
  }
}

resource "aws_autoscaling_group" "main" {
  name_prefix               = "kuali-asg-2az-"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = [for subnet in aws_subnet.private : subnet.id]
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.main.arn]
  tag {
    key                 = "Name"
    value               = "Kuali-ASG-Instance-2AZ"
    propagate_at_launch = true
  }
  depends_on = [aws_lb.main]
}

resource "aws_cloudwatch_metric_alarm" "scale_out_cpu_alarm" {
  alarm_name          = "asg-scale-out-cpu-alarm-2az"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50" 
  dimensions = { AutoScalingGroupName = aws_autoscaling_group.main.name }
  alarm_actions = [aws_autoscaling_policy.scale_out_cpu.arn]
}

resource "aws_cloudwatch_metric_alarm" "scale_in_cpu_alarm" {
  alarm_name          = "asg-scale-in-cpu-alarm-2az"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10" 
  dimensions = { AutoScalingGroupName = aws_autoscaling_group.main.name }
  alarm_actions = [aws_autoscaling_policy.scale_in_cpu.arn]
}

# Bastion Host Instance 
resource "aws_instance" "bastion" {
  ami                    = "" # Replace with a current Amazon Linux 2 AMI for your region
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id # Launch in the first public subnet
  key_name               = var.ec2_key_pair_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  # associate_public_ip_address = true # This is true by default

  tags = {
    Name = "Kuali-Bastion-Host"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  domain      = "vpc"
  tags = {
    Name = "Bastion-EIP"
  }
}
