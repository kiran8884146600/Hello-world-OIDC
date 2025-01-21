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

# Attach the AWS Lambda basic execution role policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role        = aws_iam_role.lambda_exec.name
}

# Define the Lambda function (Make sure this is named hello_world_func exactly)
resource "aws_lambda_function" "hello_world_func" {
  function_name = "hello-world-func"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = var.handler_zip_file

  # Ensure the file is deployed
  source_code_hash = filebase64sha256("./handler.zip")
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

  jwt_configuration {
    issuer   = var.issuer_url
    audience = [var.client_id]
  }
}

# Define routes for the API (GET )
resource "aws_apigatewayv2_route" "hello_world_route" {
  api_id           = aws_apigatewayv2_api.hello_world_api.id
  route_key        = "GET /hello"
  target           = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_authorizer.id
}



# Deploy the API Gateway V2
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id        = aws_apigatewayv2_api.hello_world_api.id
  depends_on    = [
    aws_apigatewayv2_route.hello_world_route,
    aws_apigatewayv2_route.hello_world_func_route
  ]
}

# Define the Stage for API Gateway deployment
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id        = aws_apigatewayv2_api.hello_world_api.id
  name          = "dev"  # The stage name (e.g., 'dev', 'prod')
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
}


