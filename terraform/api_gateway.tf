resource "aws_api_gateway_vpc_link" "api_gateway_vpc_link" {
  name        = "lb-link-${var.project_name}"
  description = "API Gateway link NLB"
  target_arns = [aws_lb.lb.arn]
}

resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  name = var.project_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api_gateway_resource_api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  http_method      = "GET"
  authorization    = "NONE"
}
resource "aws_api_gateway_method" "api_gateway_method_api" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_resource.api_gateway_resource_api.id
  http_method      = "GET"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "api_gateway_integration"{
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  http_method = aws_api_gateway_method.api_gateway_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.lb.dns_name}:${var.project_port}/"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.api_gateway_vpc_link.id
}
resource "aws_api_gateway_integration" "api_gateway_integration_api"{
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource_api.id
  http_method = aws_api_gateway_method.api_gateway_method_api .http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.lb.dns_name}:${var.project_port}/api"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.api_gateway_vpc_link.id
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_gateway_rest_api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  stage_name    = "production"
}