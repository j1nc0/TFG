resource "aws_lb_target_group" "awstp-target-group" {
  name        = "${var.project_name}-${var.workspace}-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.project_vpc.id

  health_check {
    interval            = 10
    path                = "/index.php"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = local.tags
}

resource "aws_lb" "alb_awstp" {
  name                       = "${var.project_name}-${var.workspace}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id] //internet facing alb needs to be in subnets with internet
  ip_address_type            = "ipv4"
  enable_deletion_protection = false # default

  tags = local.tags
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb_awstp.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert-alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.awstp-target-group.arn
  }
}