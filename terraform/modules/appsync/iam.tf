resource "aws_iam_role" "this" {
  name               = "${var.module_id}-role"
  assume_role_policy = data.aws_iam_policy_document.role.json
}

data "aws_iam_policy_document" "role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.module_id}-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:GetItem",
    ]
    resources = [
      var.aws_dynamodb_table.this.arn,
    ]
  }
}
