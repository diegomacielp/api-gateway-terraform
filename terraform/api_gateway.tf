resource "aws_api_gateway_vpc_link" "api_gateway_vpc_link" {
  name        = "local.namespace"
  description = "allows public API Gateway for to talk to private NLB"
  target_arns = [aws_lb.lb.arn]
}

resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  name = var.project_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id      = aws_api_gateway_resource.api_gateway_resource.id
  http_method      = "GET"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.api_gateway_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.lb.dns_name}:${var.project_port}/api"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.api_gateway_vpc_link.id
}

/*resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = var.project_name
      version = "1.0"
    }
    paths = {
      "/" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://54.160.215.195:${var.project_port}/"
          }
        }
      },
      "/api" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "http://54.160.215.195:${var.project_port}/api"
          }
        }
      }
    }
  })
  name = var.project_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
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
  stage_name    = "staging"
}

resource "aws_vpc_endpoint_service" "example" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.example.arn]
}*/ 