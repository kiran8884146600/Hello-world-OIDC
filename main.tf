provider "aws" {
  region = var.aws_region
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Lambda Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "hello_world_func" {
  function_name = "hello-world-func"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = var.handler_zip_file
  source_code_hash = filebase64sha256(var.handler_zip_file)
}

# API Gateway
resource "aws_apigatewayv2_api" "hello_world_api" {
  name          = "hello-world-api"
  protocol_type = "HTTP"
}

# Lambda Integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.hello_world_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hello_world_func.invoke_arn
  payload_format_version = "2.0"
}

# Route for /hello
resource "aws_apigatewayv2_route" "hello_world_route" {
  api_id           = aws_apigatewayv2_api.hello_world_api.id
  route_key        = "GET /hello"
  target           = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id    = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Route for root path (/)
resource "aws_apigatewayv2_route" "root_route" {
  api_id           = aws_apigatewayv2_api.hello_world_api.id
  route_key        = "GET /"
  target           = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
}

# Deployment
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id     = aws_apigatewayv2_api.hello_world_api.id
  depends_on = [
    aws_apigatewayv2_route.hello_world_route,
    aws_apigatewayv2_route.root_route,
  ]
}

# Stage
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id        = aws_apigatewayv2_api.hello_world_api.id
  name          = "dev"
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
}

# Lambda Permission
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.hello_world_api.execution_arn}/*/*"
}

# Output API Gateway URL
output "api_gateway_endpoint" {
  value = aws_apigatewayv2_stage.api_stage.invoke_url
}
