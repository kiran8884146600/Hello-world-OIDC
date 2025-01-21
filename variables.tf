
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function."
  type        = string
  default     = "hello-world-func"
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

#variable "api_name" {
 # description = "Name of the API Gateway REST API."
  #type        = string
  #default     = "APP-API"
#}

variable "stage_name" {
  description = "The deployment stage name for the API."
  type        = string
  default     = "dev"
}
variable "cognito_user_pool_client_id" {
  description = "The client ID of your Cognito User Pool"
  type        = string
  default     = "2372bcb485e4jg2bsrmekejnkh"
}

variable "cognito_user_pool_id" {
  description = "The ID of your Cognito User Pool"
  type        = string
  default     = "us-east-1_uhH5gxPJF"
}
variable "issuer_url" {
  description = "The issuer URL of the Cognito User Pool"
  type        = string
  default     = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_uhH5gxPJF"
}

variable "client_id" {
  description = "The client ID for the Cognito App Client"
  type        = string
  default     = "1jk55nbmismv4a5cm2quvbkhnl"
}

