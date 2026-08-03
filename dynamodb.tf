# =============================================================================
# dynamodb.tf
# One DynamoDB table for ShopEasy application data (orders / transactions)
# =============================================================================

resource "aws_dynamodb_table" "transactions" {
  name         = "${local.name_prefix}-transactions"
  billing_mode = "PAY_PER_REQUEST" # Cheapest and simplest for this project
  hash_key     = "id"              # Partition key (unique ID for each item)

  attribute {
    name = "id"
    type = "S" # S = String
  }

  # Optional: useful later if want to query by type (order / product)
  attribute {
    name = "entity_type"
    type = "S"
  }

  global_secondary_index {
    name            = "EntityTypeIndex"
    hash_key        = "entity_type"
    projection_type = "ALL"
  }

  # Protect against accidental deletion
  point_in_time_recovery {
    enabled = true
  }

  # Enable encryption at rest (AWS owned key – free)
  server_side_encryption {
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-transactions"
    Purpose = "ShopEasy orders-products-transactions"
  })
}