locals {
  dkim_tokens = {
    token1 = aws_sesv2_email_identity.email_identity.dkim_signing_attributes[0].tokens[0]
    token2 = aws_sesv2_email_identity.email_identity.dkim_signing_attributes[0].tokens[1]
    token3 = aws_sesv2_email_identity.email_identity.dkim_signing_attributes[0].tokens[2]
  }
}


resource "aws_route53_record" "ses_cnames" {
  for_each = local.dkim_tokens

  zone_id = var.hosting_zone_id
  name    = "${each.value}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${each.value}.dkim.amazonses.com"]
}

resource "aws_route53_record" "mx_record_for_receiving" {
  zone_id = var.hosting_zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = "300"

  records = [
    "10 inbound-smtp.us-east-1.amazonaws.com"
  ]
}