terraform {
  backend "s3" {
    bucket               = "inves-global-terraform-state"
    workspace_key_prefix = "environments"
    key                  = "inves-template-rest"
    profile              = "inves-global"
    region               = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18"
    }
  }
  required_version = ">= 1.2.2"
}

provider "aws" {
  region = "eu-west-1"
}

module "inves-template-rest-lambda" {
  source                     = "terraform-aws-modules/lambda/aws"
  function_name              = "inves-template-rest-${terraform.workspace}"
  description                = "Hello World Lambda - ${terraform.workspace}"
  handler                    = "./src/app-lambda.handler"
  runtime                    = "nodejs18.x"
  create_lambda_function_url = true
  create_package             = false
  local_existing_package     = "../build/deploy.zip"
  environment_variables = {
    STAGE   = terraform.workspace
    PROJECT = "inves-template-rest-${terraform.workspace}"
  }
  tags = {
    "env" = terraform.workspace
  }
}

output "lambda-url" {
  value = module.inves-template-rest-lambda.lambda_function_url
}
