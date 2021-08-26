data "archive_file" "this" {
  type        = "zip"
  output_path = "${path.module}/app.zip"
  source_dir  = "${path.module}/app"
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

  filename         = "${path.module}/app.zip"
  source_code_hash = data.archive_file.this.output_base64sha256

  tracing_config {
    mode = "PassThrough"
  }
}
