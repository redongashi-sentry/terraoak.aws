
resource "aws_apigatewayv2_api" "sac_apigwv2_api" {
  name          = "sac-testing-apigwv2-api"
  protocol_type = "WEBSOCKET"
}

resource "aws_apigatewayv2_api_mapping" "api" {
  api_id      = aws_apigatewayv2_api.sac_apigwv2_api.id
  domain_name = aws_apigatewayv2_domain_name.sac_apigwv2_domain.id
  stage       = aws_apigatewayv2_stage.sac_apigwv2_stage.id
}
  resource "aws_apigatewayv2_domain_name" "sac_apigwv2_domain" {
  domain_name = "testingdomain.com"
  domain_name_configuration {
    certificate_arn = "acm-cert-arn"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_1"
  }
}

resource "aws_apigatewayv2_integration" "sac_apigwv2_integration" {
  api_id           = aws_apigatewayv2_api.sac_apigwv2_api.id
  integration_type = "AWS_PROXY"
  integration_method = "PATCH"
  connection_type = "INTERNET"
  integration_uri = aws_lambda_function.sac_lambda.arn
}

resource "aws_apigatewayv2_stage" "sac_apigwv2_stage" {
  api_id = aws_apigatewayv2_api.sac_apigwv2_api.id
  name   = "sac-testing-apigwv2-stage"
  default_route_settings {
    detailed_metrics_enabled = false
    logging_level = "OFF"
  }
}

resource "aws_apigatewayv2_route" "sac_apigwv2_route" {
  api_id    = aws_apigatewayv2_api.sac_apigwv2_api.id
  route_key = "$connect"
  authorization_type = "NONE"
  api_key_required = false
  target    = "integrations/${aws_apigatewayv2_integration.sac_apigwv2_integration.id}"
}

resource "aws_route53_zone" "sac_route_zone" {
  name = "testingdomain.com"
}

resource "aws_route53_record" "sac_route_record" {
  zone_id = aws_route53_zone.sac_route_zone.id
  name    = "testingdomain.com"
  type    = "A"
  ttl     = 300
  records = ["192.0.2.1"]
}

resource "aws_vpc" "apigwv2_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "apigwv2-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.apigwv2_vpc.id
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "apigwv2_subnet" {
  vpc_id     = aws_vpc.apigwv2_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "apigwv2_subnet"
  }
}

resource "aws_subnet" "apigwv2_subnet_2" {
  vpc_id     = aws_vpc.apigwv2_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "apigwv2_security_group" {
  name        = "apigwv2-security-group"
  vpc_id      = aws_vpc.apigwv2_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["173.0.0.0/32"]
  }
  tags = {
    Name = "apigwv2_sec_group"
  }
}

resource "aws_lambda_function" "sac_lambda" {
  function_name = "insecure_lambda_function"
  role = aws_iam_role.lambda_role.arn
	filename   = "my-deployment-package.zip"
  handler = "index.handler"
  runtime = "dotnet6"
  reserved_concurrent_executions = 0
}

resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sns:Publish",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:ListShards",
          "kinesis:ListStreams",
          "lambda:GetLayerVersion",
          "lambda:InvokeFunction",
          "lambda:AddLayerVersionPermission",
          "lambda:AddPermission",
          "lamda:CreateAlias",
          "lambda:CreateEventSourceMapping",
        ]
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

resource "aws_cloudwatch_log_group" "sac_api_gatewayv2_cloudwatch_log_group" {
  name = "sac-testing-apigwv2-cloudwatch-log-group"
  tags = {
    Environment = "production"
  }
}