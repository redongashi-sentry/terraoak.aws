
resource "aws_elasticsearch_domain" "sac_elasticsearch_domain" {
  domain_name           = "sac-testing-elasticsearch"
  elasticsearch_version = "7.10"
  advanced_security_options {
    enabled                        = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "master"
      master_user_password = "$uper$ecretP@$$w0rd"
    }
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
  cluster_config {
    instance_type          = "c6g.large.elasticsearch"
    zone_awareness_enabled = false
    dedicated_master_count = 2
    instance_count         = 2
  }
  encrypt_at_rest {
    enabled = false
  }
  domain_endpoint_options {
    enforce_https       = false
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }
  node_to_node_encryption {
    enabled = false
  }
}
