locals {
  tags = {
    Project     = "${var.project_name}"
    Environment = "${var.workspace}"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  count       = var.db_type == "aurora" ? 1 : 0
  name        = lower("${var.project_name}-${var.workspace}-aurora-db-57-parameter-group")
  family      = "aurora-mysql5.7"
  description = "${var.project_name}-${var.workspace}-aurora-db-57-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "parameter_group" {
  count       = var.db_type == "aurora" ? 1 : 0
  name        = lower("${var.project_name}-${var.workspace}-aurora-57-cluster-parameter-group")
  family      = "aurora-mysql5.7"
  description = "${var.project_name}-${var.workspace}-aurora-57-cluster-parameter-group"
  tags        = local.tags
}

module "rds-aurora" {
  count         = var.db_type == "aurora" ? 1 : 0
  source        = "terraform-aws-modules/rds-aurora/aws"
  version       = "6.2.0"
  database_name = "${var.project_name}DB${var.workspace}"

  name           = lower("${var.project_name}-${var.workspace}-aurora-db")
  engine         = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.10.2"
  port           = 3306

  instances = {
    master = {
      instance_class = var.db_instance_type
    }
    reader = {
      instance_class = var.db_instance_type
    }
  }

  vpc_id                 = aws_vpc.project_vpc.id
  db_subnet_group_name   = aws_db_subnet_group.rds-db-subnet-group.name
  create_db_subnet_group = false
  create_security_group  = false
  vpc_security_group_ids = ["${aws_security_group.rds-sg.id}"]

  iam_database_authentication_enabled = true
  master_username                     = local.db_creds.username
  master_password                     = local.db_creds.password
  create_random_password              = false

  apply_immediately          = true
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true

  db_parameter_group_name         = aws_db_parameter_group.db_parameter_group[0].id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.parameter_group[0].id
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  storage_encrypted = var.db_encrypted
  source_region     = var.region

  autoscaling_enabled            = true
  autoscaling_max_capacity       = 15
  autoscaling_min_capacity       = 2
  autoscaling_scale_in_cooldown  = 180
  autoscaling_scale_out_cooldown = 180

  copy_tags_to_snapshot = true
  tags                  = local.tags
}


resource "aws_db_instance" "mydb" {
  count                      = var.db_type == "rds" ? 1 : 0
  engine                     = "mysql"
  engine_version             = "5.7.37"
  instance_class             = var.db_instance_type
  port                       = 3306
  allocated_storage          = var.db_storage
  max_allocated_storage      = var.db_storage * 10
  storage_type               = "gp2"
  publicly_accessible        = false #default
  multi_az                   = true
  identifier                 = lower("${var.project_name}-${var.workspace}-database") #name of RDS instance
  name                       = "${var.project_name}DB${var.workspace}"                #name of the database when it is cerated, if this is not specified no db is created
  username                   = local.db_creds.username
  password                   = local.db_creds.password
  storage_encrypted          = var.db_encrypted
  backup_retention_period    = var.db_backups ? 14 : null
  backup_window              = var.db_backups ? "03:46-04:16" : null
  auto_minor_version_upgrade = true #true default
  db_subnet_group_name       = aws_db_subnet_group.rds-db-subnet-group.name
  vpc_security_group_ids     = ["${aws_security_group.rds-sg.id}"]
  parameter_group_name       = "default.mysql5.7"
  skip_final_snapshot        = true

  tags = local.tags
}

#create user and db passwd

data "aws_secretsmanager_secret_version" "creds" { //most expensive technique but the most secure! 0,40 per secret + 0.05 per 10k api calls
  secret_id = var.secretmanager_secret_id
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

resource "aws_db_subnet_group" "rds-db-subnet-group" {
  name       = lower("${var.project_name}-${var.workspace}-subnet-group")
  subnet_ids = ["${aws_subnet.db_subnets[0].id}", "${aws_subnet.db_subnets[1].id}"]

  tags = local.tags
}