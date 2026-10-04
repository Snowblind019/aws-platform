resource "aws_organizations_policy" "tag_standard" {
  name = "Standard-tags"
  description = "Report-only: the four standard tag keys with exact capitalization."
  type = "TAG_POLICY"

  content = jsonencode({
    tags = {
        Project = {
            tag_key = { "@@asign" = "Project" }
        }

        ManagedBy = {
            tag_key = { "@@asign" = "ManagedBy"}
            tag_value = { "@@asign" = ["terraform"]}
        }

        Owner = {
            tag_key = { "@@asign" = "Owner"}
        }

        Ephemeral = {
            tag_key = { "@@assign" = "Ephemeral"}
            tag_value = { "@@assign" = ["true", "false"]}
        }
    }
  })
}

resource "aws_organizations_policy_attachment" "tag_standard" {
    policy_id = aws_organizations_policy.tag_standard.id
    target_id = aws_organizations_organizational_unit.workloads.id
}