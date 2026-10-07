locals {
  # GitHub OIDC subject prefix, immutable format:
  # From https://api.github.com/repos/Snowblind019/aws-platform
  github_sub_prefix = "repo:Snowblind019@153557413/aws-platform@1389881657"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "gha_ephemeral_check_trust" {
  statement {
    sid     = "GitHubActionsMainBranchOnly"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["${local.github_sub_prefix}:ref:refs/heads/main"]
    }
  }
}

data "aws_iam_policy_document" "gha_ephemeral_check_permissions" {
  statement {
    sid    = "ReadOnlyForEphemeralCheck"
    effect = "Allow"
    actions = [
      "tag:GetResources",
      "ec2:DescribeNatGateways",
      "ec2:DescribeAddresses",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "gha_ephemeral_check" {
  name                 = "gha-ephemeral-check"
  description          = "Assumed by the ephemeral-check workflow on main through GitHub OIDC. Read-only."
  assume_role_policy   = data.aws_iam_policy_document.gha_ephemeral_check_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "gha_ephemeral_check" {
  name   = "ephemeral-check-read"
  role   = aws_iam_role.gha_ephemeral_check.name
  policy = data.aws_iam_policy_document.gha_ephemeral_check_permissions.json
}
