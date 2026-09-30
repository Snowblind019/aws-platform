terraform {
  backend "s3" {
    key = "aws-platform/org/terraform.tfstate"
  }
}