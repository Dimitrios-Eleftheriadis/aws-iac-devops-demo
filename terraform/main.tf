terraform {
  required_version = ">= 1.0.9"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

# Used to get the caller identity
data "aws_caller_identity" "current" {}

resource "aws_ssm_parameter" "region" {
  type = "String"
  description = "region id"
  name = "/${var.project_name}/${terraform.workspace}/region_id"
  value = var.region[terraform.workspace]
}

resource "aws_ssm_parameter" "account_id" {
  type = "String"
  description = "account id"
  name = "/${var.project_name}/${terraform.workspace}/account_id"
  value = var.region[terraform.workspace]
}



