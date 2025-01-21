provider "aws" {
  region = var.aws_region
}

# Lambda Function
resource "aws_lambda_function" "helloworld" {
  function_name = var.lambda_function_name
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = var.handler_zip_file

  # Ensure the file is deployed
  source_code_hash = filebase64sha256("./handler.zip")

}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "app_api" {
  name = var.api_name
}

# Resource (path)
resource "aws_api_gateway_resource" "helloworld_resource" {
  rest_api_id = aws_api_gateway_rest_api.app_api.id
  parent_id   = aws_api_gateway_rest_api.app_api.root_resource_id
  path_part   = "helloworld"
}

# Method (GET)
resource "aws_api_gateway_method" "helloworld_method" {
  rest_api_id   = aws_api_gateway_rest_api.app_api.id
  resource_id   = aws_api_gateway_resource.helloworld_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.app_api.id
  resource_id             = aws_api_gateway_resource.helloworld_resource.id
  http_method             = aws_api_gateway_method.helloworld_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.helloworld.invoke_arn
}

# Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.app_api.id
  stage_name  = var.stage_name
}

# Lambda Permission
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.helloworld.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.app_api.execution_arn}/*/*"
}
