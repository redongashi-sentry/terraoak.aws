
resource "aws_elasticache_cluster" "sac_memcached_cluster" {
  cluster_id               = "sac-testing-memcached-cluster"
  engine                   = "memcached"
  node_type                = "cache.t3.small"
  num_cache_nodes          = 2
  parameter_group_name     = "default.memcached1.6"
  port                     = 11211
  subnet_group_name        = aws_elasticache_subnet_group.elasticache_subnet_group.name
  snapshot_retention_limit = 0
  az_mode                  = "single-az"
}

resource "aws_elasticache_cluster" "sac_redis_cluster" {
  cluster_id               = "sac-testing-redis-cluster"
  engine                   = "redis"
  node_type                = "cache.t3.small"
  num_cache_nodes          = 1
  parameter_group_name     = "default.redis3.2"
  engine_version           = "3.2.10"
  port                     = 6379
  subnet_group_name        = aws_elasticache_subnet_group.elasticache_subnet_group.name
  snapshot_retention_limit = 0
}

resource "aws_elasticache_replication_group" "sac_replication_group_redis" {
  preferred_cache_cluster_azs = ["us-east-2b", "us-east-2c"]
  replication_group_id        = "sac-testing-replication-group-redis"
  description                 = "sac testing replication group"
  node_type                   = "cache.t3.small"
  num_cache_clusters          = 2
  parameter_group_name        = "default.redis7"
  port                        = 6379
  multi_az_enabled            = false
  automatic_failover_enabled  = true
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false
}
