

resource "aws_launch_template" "launch_template" {
  name = "${var.project_name}-${var.workspace}-launch-template"

  image_id = data.aws_ami.amazon-linux-2.id

  instance_market_options {
    market_type = var.is_spot ? "spot" : null

    spot_options {
      max_price = var.is_spot ? var.spot_price : null
    }
  }

  instance_type = var.instance_type

  key_name = aws_key_pair.awstp_auth.key_name

  vpc_security_group_ids = [aws_security_group.web-private-sg.id]

  tags = local.tags
}

resource "aws_autoscaling_group" "dev-autoscaling-group" {
  name                      = "${var.project_name}-${var.workspace}-autoscaling-group"
  max_size                  = var.autoscaling_max_size
  min_size                  = var.autoscaling_min_size
  health_check_grace_period = 200
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.awstp-target-group.arn]
  force_delete              = true

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  vpc_zone_identifier = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${var.project_name}-${var.workspace}-private-instance"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "Project"
        "value"               = "${var.project_name}"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "Environment"
        "value"               = "${var.workspace}"
        "propagate_at_launch" = true
      }
    ],
  )
}

resource "aws_autoscaling_policy" "policy_autoscaling" {
  name                   = "${var.project_name}-${var.workspace}-policy_autoscaling"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.dev-autoscaling-group.name
  policy_type            = "SimpleScaling"
}

#Cloudwatch monitoring to define threshhold

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-autoscaling" {
  alarm_name          = "${var.project_name}-${var.workspace}-cpu-alarm-autoscaling"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.policy_scale_up

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dev-autoscaling-group.name
  }

  alarm_description = "alarm once cpu usage increases over or equal to 85% average for more than 120 secs"
  alarm_actions     = [aws_autoscaling_policy.policy_autoscaling.arn]
  tags              = local.tags
}

resource "aws_autoscaling_policy" "policy_scaledown" {
  name                   = "${var.project_name}-${var.workspace}-policy_scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.dev-autoscaling-group.name
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-descaling" {
  alarm_name          = "${var.project_name}-${var.workspace}-cpu-alarm-descaling"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.policy_scale_down

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dev-autoscaling-group.name
  }

  alarm_description = "alarm once cpu usage increases less or equal to 25% average for more than 120 secs"
  alarm_actions     = [aws_autoscaling_policy.policy_scaledown.arn]
  tags              = local.tags
}