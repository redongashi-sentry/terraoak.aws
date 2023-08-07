
resource "aws_apigatewayv2_api" "sac_apigwv2_api" {
  name          = "sac-testing-apigwv2-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_methods = ["*"]
  }
}

resource "aws_apigatewayv2_api_mapping" "api" {
  api_id      = aws_apigatewayv2_api.sac_apigwv2_api.id
  domain_name = aws_apigatewayv2_domain_name.sac_apigwv2_domain.id
  stage       = aws_apigatewayv2_stage.sac_apigwv2_stage.id
}

resource "aws_apigatewayv2_domain_name" "sac_apigwv2_domain" {
  domain_name = "testingdomain.com"
  domain_name_configuration {
    certificate_arn = "acm-certificate-arn"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_1"
  }
}

resource "aws_apigatewayv2_integration" "sac_apigwv2_integration" {
  api_id             = aws_apigatewayv2_api.sac_apigwv2_api.id
  integration_type   = "HTTP_PROXY"
  integration_method = "PATCH"
  connection_type    = "INTERNET"
  integration_uri    = aws_lb_listener.elbv2_listener.arn
  tls_config {
    server_name_to_verify = "testingdomain.com"
  }
}

resource "aws_apigatewayv2_stage" "sac_apigwv2_stage" {
  api_id = aws_apigatewayv2_api.sac_apigwv2_api.id
  name   = "sac-testing-apigwv2-stage"
}

resource "aws_apigatewayv2_route" "sac_apigwv2_route" {
  api_id             = aws_apigatewayv2_api.sac_apigwv2_api.id
  route_key          = "GET /hello"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.sac_apigwv2_integration.id}"
}
