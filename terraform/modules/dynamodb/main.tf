resource "aws_dynamodb_table" "this" {
  name           = var.module_id
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
