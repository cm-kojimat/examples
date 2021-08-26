module "dynamodb" {
  source    = "./modules/dynamodb"
  module_id = "${local.module_id}-dynamodb"
}

module "lambda" {
  source    = "./modules/lambda"
  module_id = "${local.module_id}-lambda"

  appsync_endpoint_graphql = module.appsync.aws_appsync_graphql_api.this.uris.GRAPHQL
}

module "appsync" {
  source    = "./modules/appsync"
  module_id = "${local.module_id}-appsync"

  aws_dynamodb_table = {
    this = module.dynamodb.aws_dynamodb_table.this
  }
}

module "iot" {
  source    = "./modules/iot"
  module_id = "${local.module_id}-iot"

  aws_lambda_function = {
    this = module.lambda.aws_lambda_function.this
  }
}
