terraform {
  backend "s3" {
    key = "aws-platform/bootstrap/terraform.tfstate"
  }
}