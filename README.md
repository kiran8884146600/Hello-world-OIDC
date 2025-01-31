markdown
Copy
# Hello World Application

This is a simple "Hello World" application deployed on AWS using Terraform. The application consists of an AWS Lambda function that returns a "Hello, World!" message via an API Gateway endpoint. The infrastructure is managed using Terraform, and the deployment is automated using a CI/CD workflow.

---

## Project Structure

The project is structured as follows:
hello-world-app/
├── src/
│ ├── index.js # Lambda function code
│ └── handler.zip # Zipped Lambda deployment package
├── main.tf # Terraform configuration for AWS resources
├── variables.tf # Terraform variables
├── backend.tf # Terraform backend configuration
└── .github/workflows/ci-cd.yml # CI/CD workflow for deployment

Copy

---

## File Descriptions

### 1. **`index.js`**
This file contains the Lambda function code. It is a simple Node.js function that returns a "Hello, World!" message as an HTTP response.

```javascript
exports.handler = async (event) => {
    return {
        statusCode: 200,
        headers: {
            "Content-Type": "text/html",
        },
        body: "<h1>Hello, World!</h1>",
    };
};
Why we use it:
This is the core logic of the application. It defines the behavior of the Lambda function when invoked.

2. handler.zip
This is the zipped deployment package for the Lambda function. It contains the index.js file and any other dependencies required for the Lambda function to run.

Why we use it:
AWS Lambda requires the function code to be uploaded as a deployment package. Zipping the code ensures that all necessary files are included and ready for deployment.

3. main.tf
This file contains the Terraform configuration for defining AWS resources. It includes:

AWS provider configuration.

IAM role for Lambda execution.

Lambda function definition.

API Gateway configuration with routes and integrations.

Cognito authorizer for API Gateway.

Why we use it:
Terraform is used to define and provision infrastructure as code. This file ensures that all AWS resources (Lambda, API Gateway, IAM roles, etc.) are created and configured consistently.

4. variables.tf
This file defines input variables for the Terraform configuration. It includes variables such as:

aws_region: The AWS region to deploy resources.

lambda_function_name: Name of the Lambda function.

handler_zip_file: Path to the Lambda deployment package.

cognito_user_pool_client_id: Client ID for Cognito User Pool.

issuer_url: Issuer URL for Cognito.

Why we use it:
Variables make the Terraform configuration reusable and customizable. They allow you to define values once and reuse them across multiple resources.

5. backend.tf
This file configures the Terraform backend to store the state file in an S3 bucket.

hcl
Copy
terraform {
  backend "s3" {
    bucket = "kiran271222"
    key    = "myfold/terraform.tfstate"
    region = "us-east-1"
  }
}
Why we use it:
Storing the Terraform state file in a remote backend (like S3) ensures that the state is shared and consistent across team members and CI/CD pipelines. It also prevents conflicts when multiple users are working on the same infrastructure.

6. .github/workflows/ci-cd.yml
This file defines the GitHub Actions workflow for CI/CD. It automates the deployment process whenever changes are pushed to the main branch. The workflow includes steps to:

Check out the repository.

Set up Terraform.

Configure AWS credentials using OIDC.

Create a deployment package (handler.zip).

Initialize and apply the Terraform configuration.

Why we use it:
CI/CD pipelines automate the deployment process, ensuring that changes are tested and deployed consistently. This reduces manual errors and speeds up the development cycle.

Prerequisites
Before deploying the application, ensure you have the following:

AWS Account: An AWS account with sufficient permissions to create Lambda functions, API Gateway, IAM roles, and S3 buckets.

Terraform: Terraform installed on your local machine or CI/CD environment.

Node.js: Node.js installed (version 18.x) for testing the Lambda function locally.

AWS CLI: AWS CLI configured with your credentials.

GitHub Secrets: Configure the following secrets in your GitHub repository:

AWS_ROLE_ARN: The ARN of the IAM role to assume in the CI/CD workflow.

AWS_REGION: The AWS region to deploy resources (e.g., us-east-1).

Deployment Steps
1. Clone the Repository
Clone the repository to your local machine:

bash
Copy
git clone https://github.com/your-username/hello-world-app.git
cd hello-world-app
2. Initialize Terraform
Run the following command to initialize Terraform and download the required providers:

bash
Copy
terraform init
3. Review Terraform Plan
Review the Terraform execution plan to ensure the resources will be created as expected:

bash
Copy
terraform plan
4. Apply Terraform Configuration
Deploy the infrastructure by applying the Terraform configuration:

bash
Copy
terraform apply -auto-approve
This will create the following resources:

IAM role for the Lambda function.

Lambda function with the provided handler.zip deployment package.

API Gateway with a /hello route integrated with the Lambda function.

Cognito authorizer for API Gateway.

5. Test the Application
Once the deployment is complete, you can test the application by sending a GET request to the API Gateway endpoint:

bash
Copy
curl https://<api-gateway-id>.execute-api.<region>.amazonaws.com/dev/hello
You should receive the following response:

html
Copy
<h1>Hello, World!</h1>
Run HTML
Cleanup
To destroy the resources created by Terraform, run:

bash
Copy
terraform destroy -auto-approve
This will remove all AWS resources associated with the application.
