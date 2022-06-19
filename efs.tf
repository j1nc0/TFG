resource "aws_efs_file_system" "efs" {
  creation_token   = "efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true


  lifecycle_policy {


    transition_to_ia = "AFTER_30_DAYS"
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }


  tags = {
    Name        = "${var.project_name}-${var.workspace}-EFS"
    Project     = "${var.project_name}"
    Environment = "${var.workspace}"
  }
}

resource "aws_efs_mount_target" "efs-mount-target" { #create mount point in each AZ
  count           = 2
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.db_subnets[count.index].id
  security_groups = [aws_security_group.efs-sg.id]
}