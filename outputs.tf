locals {
  export_as_organization_variable = {
    "ses_configuration_set_name" = {
      hcl       = false
      sensitive = false
      value     = var.ses_domain_verification_success ? aws_sesv2_configuration_set.ses_configuration[0].configuration_set_name : ""
    }
    "ses_verified_email_identity_source_arn" = {
      hcl       = false
      sensitive = false
      value     = aws_sesv2_email_identity.email_identity.arn
    }
    "ses_domain_verification_success" = {
      hcl       = false
      sensitive = false
      value     = aws_sesv2_email_identity.email_identity.dkim_signing_attributes[0].status == "SUCCESS"
    }
  }
}

data "tfe_organization" "organization" {
  name = var.terraform_organization
}

data "tfe_variable_set" "variables" {
  name         = "variables"
  organization = data.tfe_organization.organization.name
}

resource "tfe_variable" "output_values" {
  for_each = local.export_as_organization_variable

  key             = each.key
  value           = each.value.hcl ? jsonencode(each.value.value) : tostring(each.value.value)
  category        = "terraform"
  description     = "${each.key} variable from the ${var.service} service"
  variable_set_id = data.tfe_variable_set.variables.id
  hcl             = each.value.hcl
  sensitive       = each.value.sensitive
}