
resource "aws_lambda_alias" "test_lambda_alias" {
  name             = "alias-insecure-SaC"
  function_name    = aws_lambda_function.insecure_lambda_SAC.arn
  function_version = "$LATEST"
}

resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_alias.test_lambda_alias.arn
  destination_config {
    on_success {
      destination = aws_sns_topic.topic-sns.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_kinesis_stream.test_stream.arn
  function_name     = aws_lambda_function.insecure_lambda_SAC.arn
  starting_position = "LATEST"
  destination_config {
  }
}

resource "aws_lambda_function" "insecure_lambda_SAC" {
  function_name                  = "insecure_lambda_function"
  role                           = aws_iam_role.lambda_role.arn
  filename                       = "my-deployment-package.zip"
  handler                        = "index.handler"
  runtime                        = "dotnetcore3.1"
  reserved_concurrent_executions = 0
  layers = [aws_lambda_layer_version.lambda_layer.arn]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "*"
  function_name = aws_lambda_function.insecure_lambda_SAC.arn
  principal     = "*"
}

resource "aws_lambda_layer_version_permission" "lambda_layer_permission" {
  layer_name     = aws_lambda_layer_version.lambda_layer.arn
  version_number = 4
  principal      = "*"
  action         = "*"
  statement_id   = "dev-account"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "lambda_layer_name"
  compatible_runtimes = ["ruby2.7"]
  description         = "test description for a test config"
  filename            = "my-deployment-package.zip"
}
