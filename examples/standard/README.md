# Basic DynamoDB Table Example

This example demonstrates how to create a basic DynamoDB table with a global secondary index.

## Usage

```hcl
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

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

## Features

- Creates a DynamoDB table with `id` as the hash key
- Adds a global secondary index on `customerId` for efficient queries
- Uses on-demand billing (PAY_PER_REQUEST) by default
- Enables server-side encryption by default
- Applies custom tags

## Data Operations

The example also demonstrates:

### Creating Items

- **Cart 1**: Laptop + Mouse items for customer-123
- **Cart 2**: Keyboard item for customer-456

### Reading Data

- Uses `aws_dynamodb_table_item` data source to read cart-001
- Outputs the retrieved data to demonstrate successful operations

### Sample Data Structure

```json
{
  "id": "cart-001",
  "customerId": "customer-123",
  "items": [
    {
      "productId": "prod-001",
      "name": "Laptop",
      "quantity": 1,
      "price": 999.99
    }
  ],
  "createdAt": "2024-01-15T10:00:00Z",
  "status": "active"
}
```

## Running the Example

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Review the plan:

   ```bash
   terraform plan
   ```

3. Apply the configuration:

   ```bash
   terraform apply
   ```

## Outputs

### Table Information

- `table_info`: Complete table details including name, ARN, and configuration

### Sample Data

- `cart_1_data`: Retrieved data from cart-001 demonstrating read operations

## Use Cases

This example is perfect for:

- Learning DynamoDB table creation
- Understanding GSI configuration
- Practicing data insertion and retrieval
- Testing table operations before production use
