variables {
  name = "test-dynamodb-table"
  tags = {
    Environment = "test"
    Project     = "dynamodb-module-test"
  }
}

run "basic_table_creation" {
  command = plan

  variables {
    name     = var.name
    hash_key = "id"
    attributes = [
      {
        name = "id"
        type = "S"
      }
    ]
    tags = var.tags
  }
}

run "table_with_gsi" {
  command = plan

  variables {
    name     = "${var.name}-gsi"
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
    tags = var.tags
  }
}

run "table_with_lsi" {
  command = plan

  variables {
    name      = "${var.name}-lsi"
    hash_key  = "id"
    range_key = "timestamp"
    attributes = [
      {
        name = "id"
        type = "S"
      },
      {
        name = "timestamp"
        type = "S"
      }
    ]
    local_secondary_indexes = [
      {
        name            = "idx_local_timestamp"
        range_key       = "timestamp"
        projection_type = "KEYS_ONLY"
      }
    ]
    tags = var.tags
  }
}

run "provisioned_billing_mode" {
  command = plan

  variables {
    name           = "${var.name}-provisioned"
    hash_key       = "id"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    attributes = [
      {
        name = "id"
        type = "S"
      }
    ]
    tags = var.tags
  }
}

run "table_with_streams" {
  command = plan

  variables {
    name             = "${var.name}-streams"
    hash_key         = "id"
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
    attributes = [
      {
        name = "id"
        type = "S"
      }
    ]
    tags = var.tags
  }
}

run "table_with_encryption" {
  command = plan

  variables {
    name                           = "${var.name}-encryption"
    hash_key                       = "id"
    server_side_encryption_enabled = true
    attributes = [
      {
        name = "id"
        type = "S"
      }
    ]
    tags = var.tags
  }
}

run "table_with_point_in_time_recovery" {
  command = plan

  variables {
    name     = "${var.name}-pitr"
    hash_key = "id"
    point_in_time_recovery = {
      enabled = true
    }
    attributes = [
      {
        name = "id"
        type = "S"
      }
    ]
    tags = var.tags
  }
}

run "table_with_cloudwatch_dashboard" {
  command = plan

  variables {
    name                         = "${var.name}-dashboard"
    hash_key                     = "id"
    cloudwatch_dashboard_enabled = true
    dashboard_name               = "test-dashboard"
    attributes = [
      {
        name = "id"
        type = "S"
      }
    ]
    tags = var.tags
  }
}

run "table_with_iam_policies" {
  command = plan

  variables {
    name                = "${var.name}-iam"
    hash_key            = "id"
    create_table_policy = true
    allowed_actions     = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"]
    attributes = [
      {
        name = "id"
        type = "S"
      }
    ]
    tags = var.tags
  }
}

run "complex_table_configuration" {
  command = plan

  variables {
    name     = "${var.name}-complex"
    hash_key = "id"
    attributes = [
      {
        name = "id"
        type = "S"
      },
      {
        name = "customerId"
        type = "S"
      },
      {
        name = "timestamp"
        type = "S"
      }
    ]
    global_secondary_indexes = [
      {
        name            = "idx_global_customerId"
        hash_key        = "customerId"
        projection_type = "ALL"
      },
      {
        name            = "idx_global_timestamp"
        hash_key        = "timestamp"
        projection_type = "KEYS_ONLY"
      }
    ]
    stream_enabled   = true
    stream_view_type = "NEW_IMAGE"
    tags             = var.tags
  }
}
