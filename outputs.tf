# =============================================================================
# DynamoDB Table Outputs
# =============================================================================

output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.name
}

# =============================================================================
# DynamoDB Streams Outputs
# =============================================================================

output "table_stream_arn" {
  description = "DynamoDB table stream ARN"
  value       = aws_dynamodb_table.this.stream_arn
}

output "table_stream_label" {
  description = "DynamoDB table stream label"
  value       = aws_dynamodb_table.this.stream_label
}

# =============================================================================
# CloudWatch Dashboard Outputs
# =============================================================================

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = var.cloudwatch_dashboard_enabled ? "https://console.aws.amazon.com/cloudwatch/home#dashboards:name=${aws_cloudwatch_dashboard.this[0].dashboard_name}" : null
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = var.cloudwatch_dashboard_enabled ? aws_cloudwatch_dashboard.this[0].dashboard_name : null
}

# =============================================================================
# IAM Policy Outputs
# =============================================================================

output "basic_policy_arn" {
  description = "ARN of the basic IAM policy (if created)"
  value       = var.create_table_policy ? aws_iam_policy.basic_table_policy[0].arn : null
}

output "custom_policy_arn" {
  description = "ARN of the custom IAM policy (if provided)"
  value       = var.table_policy != null ? aws_iam_policy.custom_table_policy[0].arn : null
}
