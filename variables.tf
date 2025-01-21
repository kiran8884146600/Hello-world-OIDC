
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function."
  type        = string
  default     = "Helloworld"
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for the Lambda function."
  type        = string
  default     = "arn:aws:iam::985539789378:role/lambda"
}

variable "handler_zip_file" {
  description = "Path to the Lambda deployment package."
  type        = string
  default     = "./handler.zip"
}

variable "api_name" {
  description = "Name of the API Gateway REST API."
  type        = string
  default     = "APP-API"
}

variable "stage_name" {
  description = "The deployment stage name for the API."
  type        = string
  default     = "dev"
}
