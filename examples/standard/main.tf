terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

module "dynamodb_table" {
  source = "../../"

  name     = "example-carts"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "customerId"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "idx_global_customerId"
      hash_key        = "customerId"
      projection_type = "ALL"
    }
  ]

  cloudwatch_dashboard_enabled = true
  dashboard_name               = "example-carts-dashboard"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

# =============================================================================
# DynamoDB Data Operations Examples
# =============================================================================

# Create sample cart items
resource "aws_dynamodb_table_item" "sample_cart_1" {
  table_name = module.dynamodb_table.table_name
  hash_key   = "id"

  item = "{\"id\":{\"S\":\"cart-001\"},\"customerId\":{\"S\":\"customer-123\"},\"items\":{\"L\":[{\"M\":{\"productId\":{\"S\":\"prod-001\"},\"name\":{\"S\":\"Laptop\"},\"quantity\":{\"N\":\"1\"},\"price\":{\"N\":\"999.99\"}}},{\"M\":{\"productId\":{\"S\":\"prod-002\"},\"name\":{\"S\":\"Mouse\"},\"quantity\":{\"N\":\"2\"},\"price\":{\"N\":\"29.99\"}}}]},\"createdAt\":{\"S\":\"2024-01-15T10:00:00Z\"},\"status\":{\"S\":\"active\"}}"
}

resource "aws_dynamodb_table_item" "sample_cart_2" {
  table_name = module.dynamodb_table.table_name
  hash_key   = "id"

  item = "{\"id\":{\"S\":\"cart-002\"},\"customerId\":{\"S\":\"customer-456\"},\"items\":{\"L\":[{\"M\":{\"productId\":{\"S\":\"prod-003\"},\"name\":{\"S\":\"Keyboard\"},\"quantity\":{\"N\":\"1\"},\"price\":{\"N\":\"89.99\"}}}]},\"createdAt\":{\"S\":\"2024-01-15T11:30:00Z\"},\"status\":{\"S\":\"active\"}}"
}

# Data source to read from the table (demonstrates querying)
# Note: depends_on ensures the item is created before attempting to read it
data "aws_dynamodb_table_item" "read_cart_1" {
  table_name = module.dynamodb_table.table_name
  key        = "{\"id\":{\"S\":\"cart-001\"}}"

  depends_on = [
    aws_dynamodb_table_item.sample_cart_1
  ]
}

# Output the read data to demonstrate successful retrieval
output "cart_1_data" {
  description = "Data read from cart-001"
  value       = jsondecode(data.aws_dynamodb_table_item.read_cart_1.item)
}

# Output table information
output "table_info" {
  description = "DynamoDB table information"
  value = {
    name      = module.dynamodb_table.table_name
    arn       = module.dynamodb_table.table_arn
    hash_key  = "id"
    gsi_count = 1
  }
}
