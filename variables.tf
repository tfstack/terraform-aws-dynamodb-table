variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key"
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either 'PROVISIONED' or 'PAY_PER_REQUEST'."
  }
}

variable "read_capacity" {
  description = "The number of read units for this table. If the billing_mode is PROVISIONED, this field is required"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "The number of write units for this table. If the billing_mode is PROVISIONED, this field is required"
  type        = number
  default     = null
}

variable "attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes"
  type = list(object({
    name = string
    type = string
  }))
  validation {
    condition = alltrue([
      for attr in var.attributes : contains(["S", "N", "B"], attr.type)
    ])
    error_message = "Attribute type must be one of: S (String), N (Number), B (Binary)."
  }
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes to create"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
  validation {
    condition = alltrue([
      for gsi in var.global_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)
    ])
    error_message = "Projection type must be one of: ALL, KEYS_ONLY, INCLUDE."
  }
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes to create"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []
  validation {
    condition = alltrue([
      for lsi in var.local_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], lsi.projection_type)
    ])
    error_message = "Projection type must be one of: ALL, KEYS_ONLY, INCLUDE."
  }
}

variable "point_in_time_recovery" {
  description = "Point-in-time recovery options"
  type = object({
    enabled = bool
  })
  default = {
    enabled = false
  }
}

variable "server_side_encryption_enabled" {
  description = "Indicates whether server-side encryption is enabled"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "The ARN of the CMK that should be used for the AWS KMS encryption"
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Indicates whether Streams are to be enabled (true) or disabled (false)"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream"
  type        = string
  default     = null
  validation {
    condition     = var.stream_view_type == null || (var.stream_view_type == "NEW_IMAGE" || var.stream_view_type == "OLD_IMAGE" || var.stream_view_type == "NEW_AND_OLD_IMAGES" || var.stream_view_type == "KEYS_ONLY")
    error_message = "Stream view type must be one of: NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY."
  }
}

variable "cloudwatch_dashboard_enabled" {
  description = "Whether to create a CloudWatch dashboard for the DynamoDB table"
  type        = bool
  default     = false
}

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard. If not provided, defaults to table name with '-dashboard' suffix"
  type        = string
  default     = null
}

variable "table_policy" {
  description = "Custom IAM policy document for the DynamoDB table"
  type        = string
  default     = null
}

variable "create_table_policy" {
  description = "Whether to create a basic IAM policy for the DynamoDB table"
  type        = bool
  default     = false
}

variable "allowed_actions" {
  description = "List of DynamoDB actions to allow in the basic policy"
  type        = list(string)
  default     = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem", "dynamodb:Query", "dynamodb:Scan"]
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
