provider "aws" {
  region = var.aws_region
}

# Create the IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWS Lambda basic execution role policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role        = aws_iam_role.lambda_exec.name
}

# Lambda Function
resource "aws_lambda_function" "hello-world-func" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = var.handler_zip_file

  # Ensure the file is deployed
  source_code_hash = filebase64sha256("./handler.zip")
}

# Create HTTP API Gateway
resource "aws_apigatewayv2_api" "app_api" {
  name          = var.api_name
  protocol_type = "HTTP"
}

# Create an HTTP API route (e.g., /hello-world)
resource "aws_apigatewayv2_resource" "hello-world-func_resource" {
  api_id   = aws_apigatewayv2_api.app_api.id
  parent_id = aws_apigatewayv2_api.app_api.api_endpoint
  path_part = "hello-world"
}

# Create Cognito User Pool Authorizer for HTTP API
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id            = aws_apigatewayv2_api.app_api.id
  authorizer_type   = "JWT"
  name              = "CognitoAuthorizer"
  identity_sources  = ["$request.header.Authorization"]
  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]  # The client ID of your Cognito User Pool
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${var.cognito_user_pool_id}"  # Cognito User Pool Issuer URL
  }
}

# API Gateway Integration to Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                = aws_apigatewayv2_api.app_api.id
  integration_type      = "AWS_PROXY"
  integration_method    = "POST"
  integration_uri       = aws_lambda_function.hello-world-func.invoke_arn
  payload_format_version = "2.0"
}

# Create HTTP API route method (GET) with Cognito JWT Authorizer
resource "aws_apigatewayv2_route" "hello-world-func_route" {
  api_id             = aws_apigatewayv2_api.app_api.id
  route_key          = "GET /hello-world"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Deployment of the API
resource "aws_apigatewayv2_deployment" "api_deployment" {
  depends_on  = [aws_apigatewayv2_route.hello-world-func_route]
  api_id      = aws_apigatewayv2_api.app_api.id
}

# Lambda Permission to allow API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello-world-func.arn
  principal     = "apigateway.amazonaws.com"
}

# Output API Gateway URL for easy access
output "api_url" {
  value = aws_apigatewayv2_api.app_api.api_endpoint
}
