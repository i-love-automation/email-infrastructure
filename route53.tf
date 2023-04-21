resource "aws_route53_record" "ses_cnames" {
  for_each = toset(aws_sesv2_email_identity.email_identity.dkim_signing_attributes[0].tokens)

  zone_id = var.hosting_zone_id
  name    = "${each.key}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${each.key}.dkim.amazonses.com"]
}
