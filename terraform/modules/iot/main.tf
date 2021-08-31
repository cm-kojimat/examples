resource "random_string" "this" {
  count   = 5
  length  = 8
  upper   = false
  special = false
}

resource "aws_iot_thing" "this" {
  for_each = merge({}, [for i, v in random_string.this : { "${i}" : v }]...)
  name     = "${var.module_id}-${each.value.result}"
}

resource "aws_iot_topic_rule" "this" {
  name        = replace("${var.module_id}_rule", "-", "_")
  enabled     = true
  sql_version = "2016-03-23"
  sql         = <<SQL
  SELECT topic() AS topic, topic(6) AS shadow_name, * FROM "$aws/things/+/shadow/name/+/update/accepted"
  SQL

  lambda {
    function_arn = var.aws_lambda_function.this.arn
  }
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = var.aws_lambda_function.this.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.this.arn
}

output "aws_iot_thing" { value = { this = aws_iot_thing.this } }
