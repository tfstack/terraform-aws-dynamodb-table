data "aws_region" "current" {}

resource "aws_dynamodb_table" "this" {
  name           = var.name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      read_capacity      = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", var.read_capacity) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", var.write_capacity) : null
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery.enabled
  }

  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.server_side_encryption_enabled && var.kms_key_arn != null ? var.kms_key_arn : null
  }

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  tags = var.tags
}

# IAM Policy for DynamoDB table access
data "aws_iam_policy_document" "basic_table_policy" {
  count = var.create_table_policy ? 1 : 0

  statement {
    effect  = "Allow"
    actions = var.allowed_actions
    resources = [
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "basic_table_policy" {
  count  = var.create_table_policy ? 1 : 0
  name   = "${var.name}-basic-policy"
  policy = data.aws_iam_policy_document.basic_table_policy[0].json

  tags = var.tags
}

resource "aws_iam_policy" "custom_table_policy" {
  count  = var.table_policy != null ? 1 : 0
  name   = "${var.name}-custom-policy"
  policy = var.table_policy

  tags = var.tags
}

# CloudWatch Dashboard for DynamoDB table monitoring
resource "aws_cloudwatch_dashboard" "this" {
  count          = var.cloudwatch_dashboard_enabled ? 1 : 0
  dashboard_name = var.dashboard_name != null ? var.dashboard_name : "${var.name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.name],
            [".", "ConsumedWriteCapacityUnits", ".", "."],
            [".", "ProvisionedReadCapacityUnits", ".", "."],
            [".", "ProvisionedWriteCapacityUnits", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "Read/Write Capacity"
          period  = 300
          stat    = "Sum"
          region  = data.aws_region.current.region
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", var.name, "Operation", "GetItem"],
            [".", ".", ".", ".", ".", "PutItem"],
            [".", ".", ".", ".", ".", "UpdateItem"],
            [".", ".", ".", ".", ".", "DeleteItem"],
            [".", ".", ".", ".", ".", "Query"],
            [".", ".", ".", ".", ".", "Scan"]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "Request Latency (ms)"
          period  = 300
          stat    = "Average"
          region  = data.aws_region.current.region
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/DynamoDB", "ThrottledRequests", "TableName", var.name, "Operation", "GetItem"],
            [".", ".", ".", ".", ".", "PutItem"],
            [".", ".", ".", ".", ".", "UpdateItem"],
            [".", ".", ".", ".", ".", "DeleteItem"],
            [".", ".", ".", ".", ".", "Query"],
            [".", ".", ".", ".", ".", "Scan"]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "Throttled Requests"
          period  = 300
          stat    = "Sum"
          region  = data.aws_region.current.region
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/DynamoDB", "ItemCount", "TableName", var.name],
            [".", "TableSizeBytes", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "Table Size & Item Count"
          period  = 300
          stat    = "Average"
          region  = data.aws_region.current.region
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      }
    ]
  })
}
