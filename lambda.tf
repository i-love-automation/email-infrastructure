module "templated_lambda" {
  source       = "github.com/codingones/terraform-remote-template-renderer"
  template_url = "https://raw.githubusercontent.com/codingones/templates/main/lambda/email_forwarding_from_ses.js"
  template_variables = {
    EMAILS = var.domain_email_forward_addresses
    DOMAIN = var.domain_name
    BUCKET = local.ses_bucket_name
  }
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source {
    content  = module.templated_lambda.rendered
    filename = "index.js"
  }
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "email_forwarding" {
  function_name    = "email_forwarding"
  handler          = "index.handler" # This should match your Lambda function's handler in the JavaScript code
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
  timeout          = 30
  publish          = true
}

resource "aws_lambda_permission" "allow_ses" {
  statement_id  = "AllowSESToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_forwarding.function_name
  principal     = "ses.amazonaws.com"
  source_arn    = "arn:aws:ses:us-east-1:${data.aws_caller_identity.current_iam.account_id}:receipt-rule-set/${aws_ses_receipt_rule_set.rule_set.rule_set_name}:receipt-rule/email_forwarding"
}
