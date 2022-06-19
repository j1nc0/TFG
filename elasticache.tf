resource "aws_elasticache_cluster" "memcached" {
  count                = var.elasticache_engine == "memcached" ? 1 : 0
  cluster_id           = "memcached-cluster"
  engine               = "memcached"
  node_type            = var.elasticache_instance_type
  num_cache_nodes      = var.number_read_replicas
  az_mode              = var.number_read_replicas > 1 ? "cross-az" : "single-az"
  subnet_group_name    = aws_elasticache_subnet_group.efs-subnet-group.name
  parameter_group_name = "default.memcached1.6"
  security_group_ids   = [aws_security_group.elasticache-sg.id]
  port                 = 11211
  tags                 = local.tags
}

resource "aws_elasticache_replication_group" "redis-multi-AZ-WP" {
  count                         = !var.cluster_mode && var.elasticache_engine == "redis" ? 1 : 0
  automatic_failover_enabled    = true
  multi_az_enabled              = true
  at_rest_encryption_enabled    = var.elasticache_encrypted
  replication_group_id          = "redis-multi-AZ-WP"
  replication_group_description = "multi AZ redis"
  node_type                     = var.elasticache_instance_type
  number_cache_clusters         = var.number_read_replicas
  parameter_group_name          = "default.redis6.x"
  port                          = 6379
  auto_minor_version_upgrade    = true
  subnet_group_name             = aws_elasticache_subnet_group.efs-subnet-group.name
  security_group_ids            = [aws_security_group.elasticache-sg.id]
  tags                          = local.tags
}

resource "aws_elasticache_replication_group" "redis-multi-AZ-WP-cluster" {
  count                         = var.cluster_mode && var.elasticache_engine == "redis" ? 1 : 0
  automatic_failover_enabled    = true
  multi_az_enabled              = true
  at_rest_encryption_enabled    = var.elasticache_encrypted
  replication_group_id          = "redis-multi-AZ-WP-cluster"
  replication_group_description = "multi AZ redis with cluster mode"
  node_type                     = var.elasticache_instance_type
  parameter_group_name          = "default.redis6.x.cluster.on"
  port                          = 6379
  auto_minor_version_upgrade    = true
  subnet_group_name             = aws_elasticache_subnet_group.efs-subnet-group.name
  security_group_ids            = [aws_security_group.elasticache-sg.id]

  cluster_mode {
    num_node_groups         = 2
    replicas_per_node_group = var.number_read_replicas - 1
  }
  tags = local.tags
}

resource "aws_elasticache_subnet_group" "efs-subnet-group" {
  name       = "${var.project_name}-${var.workspace}-elasticache-subnet-group"
  subnet_ids = ["${aws_subnet.db_subnets[0].id}", "${aws_subnet.db_subnets[1].id}"]
  tags       = local.tags
}
