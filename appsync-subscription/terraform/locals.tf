resource "random_string" "this" {
  length  = 8
  upper   = false
  special = false
}

locals {
  module_id = random_string.this.result
}
