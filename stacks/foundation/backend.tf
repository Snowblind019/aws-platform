terraform {
  backend "s3" {
    key = "aws-platform/foundation/terraform.tfstate"
    
  }
}