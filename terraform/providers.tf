provider "aws" {
  region = var.region[terraform.workspace]
  assume_role {
    role_arn = "arn:aws:iam::${var.account[terraform.workspace]["id"]}:role/${var.project_name}-${var.region_label[terraform.workspace]}-app-${terraform.workspace}-iam-role-terraform-backend"
  }
}
