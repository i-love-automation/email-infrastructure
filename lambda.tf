locals {
  runner_home = "/home/runner/work/email-infrastructure/email-infrastructure"
}

module "templated_lambda" {
  source       = "github.com/codingones/terraform-remote-template-renderer"
  template_url = "https://raw.githubusercontent.com/codingones/templates/main/lambda/email_forwarding_from_ses.js"
  template_variables = {
    EMAILS = var.domain_email_forward_addresses
    DOMAIN = var.domain_name
    BUCKET = local.ses_bucket_name
  }
}

data "http" "packagejson" {
  url = "https://raw.githubusercontent.com/codingones/templates/main/lambda/email_forwarding_from_ses.dependencies.json"
}

resource "null_resource" "create_directory" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/lambda"
  }
}

resource "local_file" "indexjs" {
  content  = module.templated_lambda.rendered
  filename = "${path.module}/lambda/index.js"

  depends_on = [null_resource.create_directory]
}

resource "local_file" "packagejson" {
  content  = data.http.packagejson.response_body
  filename = "${path.module}/lambda/package.json"

  depends_on = [null_resource.create_directory]
}

resource "null_resource" "install_lambda_dependencies" {
  provisioner "local-exec" {
    command = "which npm"
  }

  depends_on = [local_file.indexjs, local_file.packagejson]
}

data "archive_file" "lambda_zip" {
  type = "zip"

  source_dir = "${path.module}/lambda"

  output_path = "${path.module}/lambda_function.zip"

  depends_on = [null_resource.install_lambda_dependencies]
}

resource "aws_lambda_function" "email_forwarding" {
  function_name    = "email_forwarding"
  handler          = "index.handler" # This should match your Lambda function's handler in the JavaScript code
  runtime          = "nodejs18.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
  timeout          = 30
  publish          = true

  depends_on = [data.archive_file.lambda_zip]
}

resource "aws_lambda_permission" "allow_ses" {
  statement_id  = "AllowSESToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_forwarding.function_name
  principal     = "ses.amazonaws.com"
  source_arn    = "arn:aws:ses:us-east-1:${data.aws_caller_identity.current_iam.account_id}:receipt-rule-set/${aws_ses_receipt_rule_set.rule_set.rule_set_name}:receipt-rule/email_forwarding"
}
