resource "aws_sesv2_email_identity" "email_identity" {
  email_identity = var.domain_name

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }
}

resource "aws_sesv2_configuration_set" "ses_configuration" {
  count = var.ses_domain_verification_success ? 1 : 0

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
}


resource "aws_ses_receipt_rule_set" "rule_set" {
  rule_set_name = "email_forwarding_rule_set"
}

resource "aws_ses_receipt_rule" "email_forwarding" {
  name          = "email_forwarding"
  rule_set_name = aws_ses_receipt_rule_set.rule_set.rule_set_name
  recipients    = ["${var.domain_name}"]
  enabled       = true

  s3_action {
    position        = 1
    bucket_name    = aws_lambda_function.email_forwarding.arn
    object_key_prefix = "emails/"
  }

  lambda_action {
    position        = 2
    function_arn    = aws_lambda_function.email_forwarding.arn
    invocation_type = "Event"
  }

  depends_on = [aws_lambda_permission.allow_ses]
}
