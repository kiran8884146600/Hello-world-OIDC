provider "aws" {
  region = var.aws_region
   
}

# Define IAM role for Lambda function execution (assuming it doesn't exist already)
resource "aws_iam_role" "lambda_exec" {
  name               = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Define the Lambda function (Make sure this is named hello_world_func exactly)
resource "aws_lambda_function" "hello_world_func" {
  function_name = "hello-world-function"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

 
}

# Define the API Gateway V2 API
resource "aws_apigatewayv2_api" "hello_world_api" {
  name          = "hello-world-api"
  protocol_type = "HTTP"
}

# Define the Lambda integration with API Gateway V2
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.hello_world_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.hello_world_func.invoke_arn
  payload_format_version = "2.0"
}

# Define the Cognito authorizer for the API Gateway V2
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id            = aws_apigatewayv2_api.hello_world_api.id
  authorizer_type   = "JWT"
  name              = "cognito-authorizer"
  identity_sources  = ["$request.header.Authorization"]
}

# Define routes for the API (GET and POST)
resource "aws_apigatewayv2_route" "hello_world_route" {
  api_id    = aws_apigatewayv2_api.hello_world_api.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "hello_world_func_route" {
  api_id        = aws_apigatewayv2_api.hello_world_api.id
  route_key     = "POST /hello"
  target        = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Deploy the API Gateway V2
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id        = aws_apigatewayv2_api.hello_world_api.id
  depends_on    = [aws_apigatewayv2_route.hello_world_func_route]
}

# Output the API Gateway URL
output "api_url" {
  value = aws_apigatewayv2_api.hello_world_api.api_endpoint
}


