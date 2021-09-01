resource "aws_appsync_graphql_api" "this" {
  name   = var.module_id
  schema = file("${path.module}/resources/schema.graphql")

  authentication_type = "API_KEY"
}

resource "aws_appsync_api_key" "this" {
  api_id = aws_appsync_graphql_api.this.id
}

resource "aws_appsync_datasource" "dynamodb" {
  api_id           = aws_appsync_graphql_api.this.id
  name             = replace("${var.module_id}_dynamodb", "-", "_")
  service_role_arn = aws_iam_role.this.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = var.aws_dynamodb_table.this.name
  }
}

resource "aws_appsync_resolver" "this" {
  for_each = {
    data_list = {
      type        = "Query"
      field       = "dataList"
      data_source = aws_appsync_datasource.dynamodb.name
    }
    get_data = {
      type        = "Query"
      field       = "getData"
      data_source = aws_appsync_datasource.dynamodb.name
    }
    create_data = {
      type        = "Mutation"
      field       = "createData"
      data_source = aws_appsync_datasource.dynamodb.name
    }
  }

  api_id      = aws_appsync_graphql_api.this.id
  field       = lookup(each.value, "field")
  type        = lookup(each.value, "type")
  data_source = lookup(each.value, "data_source")

  request_template  = file("${path.module}/resources/resolvers/${each.key}/request.template")
  response_template = file("${path.module}/resources/resolvers/${each.key}/response.template")
}
