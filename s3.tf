locals {
  ses_bucket_name = "${var.project}-${var.service}"
}

resource "aws_s3_bucket" "email" {
  bucket        = local.ses_bucket_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_policy" "ses_email_bucket_policy" {
  bucket = aws_s3_bucket.email.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSES"
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Resource = "${aws_s3_bucket.email.arn}/*"
        Condition = {
          StringEquals = {
            "aws:Referer" = data.aws_caller_identity.current_iam.account_id
          }
        }
      }
    ]
  })
}