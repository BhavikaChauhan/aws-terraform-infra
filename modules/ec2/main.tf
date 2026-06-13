resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  # Bootstrap script — installs Docker, AWS CLI, Nginx on first boot
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    environment  = var.environment
    project_name = var.project_name
  }))

  tags = {
    Name = "${var.project_name}-${var.environment}-server"
  }

  lifecycle {
    # Prevent accidental destroy in prod
    prevent_destroy = false  # Set to true for real prod
    ignore_changes  = [ami]  # Don't replace on AMI updates
  }
}

# Elastic IP — stable public IP that survives restarts
resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip"
  }
}

# CloudWatch billing alarm — notify if cost goes over $5
resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "${var.project_name}-${var.environment}-billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400  # 24 hours
  statistic           = "Maximum"
  threshold           = 5
  alarm_description   = "Billing alert — charges exceeded $5"
  alarm_actions       = []  # Add SNS topic ARN for email alerts

  dimensions = {
    Currency = "USD"
  }
}
