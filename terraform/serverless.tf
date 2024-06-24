resource "aws_s3_bucket" "serverless_deployment_bucket" {

    bucket = "${var.project_name}-${var.region_label[terraform.workspace]}-app-${terraform.workspace}-s3-serverless-deployments"

}

resource "aws_ssm_parameter" "serverless_deployment_bucket" {
    type = "String"
    description = "The ssm parameter for the serverless deployment bucket"
    name = "/${var.project_name}/${terraform.workspace}/serverless_deployment_bucket"
    value = aws_s3_bucket.serverless_deployment_bucket.id
}