
resource "aws_dynamodb_table" "dynamo-db-table" {
  name                        = "sactestingtable"
  billing_mode                = "PROVISIONED"
  hash_key                    = "UserId"
  range_key                   = "GameTitle"
  read_capacity               = 1
  write_capacity              = 1
  deletion_protection_enabled = false
  attribute {
    name = "UserId"
    type = "S"
  }
  attribute {
    name = "GameTitle"
    type = "S"
  }
  attribute {
    name = "TopScore"
    type = "N"
  }
  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }
  point_in_time_recovery {
    enabled = false
  }
  timeouts {
    create = "10m"
    delete = "10m"
    update = "1h"
  }
  global_secondary_index {
    name               = "GameTitleIndex"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }
  server_side_encryption {
    enabled = false
  }
}
