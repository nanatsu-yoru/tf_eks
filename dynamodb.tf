resource "aws_dynamodb_table" "states_lock" {
  for_each       = toset(local.dynamodb_table)
  name           = each.key
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "prepare_lock" {
  name           = "terraform-lock-prepare"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "tf-lock" {
  name           = "tf-lock.${var.account_id}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}