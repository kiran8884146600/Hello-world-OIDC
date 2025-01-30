# AWS Lambda with API Gateway and Cognito Authorizer

This repository contains Terraform code to deploy an AWS Lambda function integrated with an API Gateway (HTTP API) and secured using a Cognito Authorizer.

## Overview

The Terraform configuration in this repository provisions the following AWS resources:

1. **IAM Role for Lambda Execution**: Creates an IAM role with the necessary permissions for the Lambda function to execute.
2. **AWS Lambda Function**: Deploys a Node.js-based Lambda function (`hello-world-func`) with a handler named `index.handler`.
3. **API Gateway (HTTP API)**: Sets up an HTTP API with a single route (`GET /hello`) that triggers the Lambda function.
4. **Cognito Authorizer**: Configures a JWT-based authorizer using Cognito to secure the API Gateway route.
5. **API Gateway Deployment and Stage**: Deploys the API Gateway and creates a `dev` stage for the API.

## Prerequisites

Before using this Terraform configuration, ensure you have the following:

1. **Terraform Installed**: Install Terraform from [here](https://www.terraform.io/downloads.html).
2. **AWS CLI Configured**: Set up your AWS credentials using the AWS CLI or environment variables.
3. **Node.js Lambda Handler**: A ZIP file containing the Node.js Lambda function code (e.g., `handler.zip`).
4. **Cognito User Pool**: A Cognito User Pool and App Client configured with the necessary `issuer_url` and `client_id`.

## Variables

The following variables are required to be set in a `terraform.tfvars` file or passed via the command line:

- `aws_region`: The AWS region where resources will be deployed (e.g., `us-east-1`).
- `handler_zip_file`: The path to the ZIP file containing the Lambda function code (e.g., `./handler.zip`).
- `issuer_url`: The issuer URL for the Cognito User Pool (e.g., `https://cognito-idp.<region>.amazonaws.com/<user-pool-id>`).
- `client_id`: The client ID of the Cognito App Client.

Example `terraform.tfvars` file:

```hcl
aws_region      = "us-east-1"
handler_zip_file = "./handler.zip"
issuer_url      = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_abc123xyz"
client_id       = "your-cognito-client-id"
