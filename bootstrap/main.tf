module "tags" {
    source = "../modules/tags"

    project = "bootstrap"
    ephemeral = false  
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "snowblind019"
} 

resource "aws_s3_bucket" "state" {
  bucket = "${local.name_prefix}-tfstate-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }
}