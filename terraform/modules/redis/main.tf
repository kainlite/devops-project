resource "aws_elasticache_cluster" "this" {
  cluster_id           = var.cluster_name
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = var.security_group_ids
  tags                 = var.tags
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = var.subnet_ids
}
