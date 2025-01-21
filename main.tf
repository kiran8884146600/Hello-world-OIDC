provider "aws" {
  region = var.aws_region
}

# Lambda Function
resource "aws_lambda_function" "hello-world-func" {
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

# Create a resource (e.g., /hello-world) under the API
resource "aws_api_gateway_resource" "hello-world-func_resource" {
  rest_api_id = aws_api_gateway_rest_api.app_api.id
  parent_id   = aws_api_gateway_rest_api.app_api.root_resource_id
  path_part   = "hello-world-func"  # This will define the path /hello-world
}
# API Gateway Method (e.g., GET method on /hello-world)
resource "aws_api_gateway_method" "hello-world-func_method" {
  rest_api_id   = aws_api_gateway_rest_api.app_api.id
  resource_id   = aws_api_gateway_resource.hello-world-func_resource.id
  http_method   = "GET"
  authorization = "NONE"  # Adjust as needed, e.g., use AWS_IAM for authorization
}

# API Gateway Integration to Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.app_api.id
  resource_id             = aws_api_gateway_resource.hello-world-func_resource.id
  http_method             = aws_api_gateway_method.hello-world-func_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello-world-func.invoke_arn  # Ensure this is correct
}


# Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.app_api.id
  stage_name  = var.stage_name
}

# Lambda Permission to allow API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello-world-func.arn
  principal     = "apigateway.amazonaws.com"
}
