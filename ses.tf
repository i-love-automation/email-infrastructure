resource "aws_sesv2_email_identity" "email_identity" {
  email_identity = var.domain_name

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }
}

data "aws_sesv2_email_identity" "email_identity_data" {
  email      = aws_sesv2_email_identity.email_identity.email
  depends_on = [aws_sesv2_email_identity.email_identity]
}

resource "aws_sesv2_configuration_set" "ses_configuration" {
  count = data.aws_sesv2_email_identity.email_identity_data.dkim_signing_attributes[0].status == "SUCCESS" ? 1 : 0

  configuration_set_name = "project_configuration_set"

  delivery_options {
    tls_policy = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = true
  }

  sending_options {
    sending_enabled = true
  }

  suppression_options {
    suppressed_reasons = ["BOUNCE", "COMPLAINT"]
  }

  tracking_options {
    custom_redirect_domain = var.domain_name
  }

  tags = local.tags

  depends_on = [aws_sesv2_email_identity.email_identity]
}