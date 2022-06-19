resource "aws_launch_template" "launch_template-bastion" {
  name = "${var.project_name}-${var.workspace}-bastion-launch_template"

  block_device_mappings { #increase drive storage
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }

  image_id = data.aws_ami.amazon-linux-2.id

  instance_market_options {
    market_type = var.is_spot ? "spot" : null

    spot_options {
      max_price = var.is_spot ? var.spot_price : null
    }
  }

  instance_type = "t3.micro"

  key_name = aws_key_pair.awstp_auth.key_name

  vpc_security_group_ids = [aws_security_group.bastion-sg.id]

  tags = local.tags
}

resource "aws_autoscaling_group" "bastion-autoscaling-group" {
  name                      = "${var.project_name}-${var.workspace}-bastion-autoscaling_group"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 100
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_template {
    id      = aws_launch_template.launch_template-bastion.id
    version = aws_launch_template.launch_template-bastion.latest_version
  }
  vpc_zone_identifier = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]



  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${var.project_name}-${var.workspace}-bastion-host"
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