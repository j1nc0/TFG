resource "aws_security_group" "bastion-sg" {
  name        = "${var.project_name}-${var.workspace}-bastion-sg"
  description = "bastion host security group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    cidr_blocks = ["${var.personal_ip}/32"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-bastion-sg"
  }
}

resource "aws_security_group" "web-public-sg" {
  name        = "${var.project_name}-${var.workspace}-web-public-sg"
  description = "used for deploying instances in public web subnets"
  vpc_id      = aws_vpc.project_vpc.id

  ingress { #http access from alb
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress { #https access from alb
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-web-public-sg"
  }
}

resource "aws_security_group" "web-private-sg" {
  name        = "${var.project_name}-${var.workspace}-web-private-sg"
  description = "sg assigned to web private instnaces of the autoscaling group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress { #http access from alb
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress { #https access from alb
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    security_groups = [aws_security_group.web-public-sg.id]
    from_port       = 22
    protocol        = "tcp"
    to_port         = 22
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-web-private-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.workspace}-alb-sg"
  description = "alb security group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-alb-sg"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "${var.project_name}-${var.workspace}-rds-sg"
  description = "rds/aurora security group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    security_groups = [aws_security_group.web-private-sg.id]
    from_port       = 3306
    protocol        = "tcp"
    to_port         = 3306
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-rds-sg"
  }
}


resource "aws_security_group" "efs-sg" {
  name        = "${var.project_name}-${var.workspace}-efs-sg"
  description = "efs security group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    security_groups = [aws_security_group.web-private-sg.id]
    from_port       = 2049
    protocol        = "tcp"
    to_port         = 2049
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-efs-sg"
  }
}

resource "aws_security_group" "elasticache-sg" {
  name        = "${var.project_name}-${var.workspace}-elasticache-sg"
  description = "redis/memcached security group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    security_groups = [aws_security_group.web-private-sg.id]
    from_port       = var.elasticache_engine == "memcached" ? 11211 : 6379
    protocol        = "tcp"
    to_port         = var.elasticache_engine == "memcached" ? 11211 : 6379
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    "Name" = "${var.project_name}-${var.workspace}-elasticache-sg"
  }
}

