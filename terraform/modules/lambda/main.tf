data "archive_file" "this" {
  depends_on = [null_resource.npm_build]

  type        = "zip"
  output_path = "${path.module}/dist.zip"
  source_dir  = "${path.module}/app/dist"
}

resource "null_resource" "npm_build" {
  provisioner "local-exec" {
    command = <<EOS
    cd "${path.module}/app"
    npm run build
    EOS
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name = "${var.module_id}-role"

  assume_role_policy  = data.aws_iam_policy_document.this.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSLambdaExecute"]
}

resource "aws_lambda_function" "this" {
  function_name = var.module_id
  role          = aws_iam_role.this.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  filename         = "${path.module}/dist.zip"
  source_code_hash = data.archive_file.this.output_base64sha256

  environment {
    variables = {
      APPSYNC_API_KEY          = var.appsync_api_key
      APPSYNC_ENDPOINT_GRAPHQL = var.appsync_endpoint_graphql
    }
  }

  tracing_config {
    mode = "PassThrough"
  }
}
