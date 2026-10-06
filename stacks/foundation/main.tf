module "tags" {
  source = "../../modules/tags"

  project   = "foundation"
  ephemeral = false
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix     = "snowblind019"
  state_bucket    = "${local.name_prefix}-tfstate-${data.aws_caller_identity.current.account_id}"
  allowed_regions = data.terraform_remote_state.org.outputs.allowed_regions
}

data "terraform_remote_state" "org" {
  backend = "s3"

  config = {
    bucket = local.state_bucket
    key    = "aws-platform/org/terraform.tfstate"
    region = "us-west-2"
  }
}