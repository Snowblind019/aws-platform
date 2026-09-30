provider "aws" {
  region  = "us-west-2"
  profile = var.mgmt_profile

  default_tags {
    tags = module.tags.tags
  }
}