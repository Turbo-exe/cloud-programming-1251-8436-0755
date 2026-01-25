# NOTE
# As per this post https://github.com/hashicorp/terraform/issues/18422#issuecomment-403908165
# this approach for packaging code is not encouraged by terraform. For the purposes of this project it is kept,
# but in a productive setting this should be replaced by a job in a CI/CD pipeline.
data archive_file lambda_packaged_code {
  for_each    = var.lambda_functions
  type        = "zip"
  source_dir  = each.value.relative_path
  output_path = "build/function-${each.value.endpoint}.zip"
}

resource aws_cloudwatch_log_group lambda_function_log_group {
  name              = "/aws/lambda/${var.project.shortcode}-${var.region}-lambda-functions"
  retention_in_days = 7
}

resource aws_lambda_function lambda_function {
  for_each = var.lambda_functions

  # Per Lambda function
  filename         = data.archive_file.lambda_packaged_code[each.key].output_path
  function_name    = "${var.project.shortcode}-${var.region}-lambda-${each.value.endpoint}"
  handler          = "${each.value.handler_module}.${each.value.handler_method}"
  source_code_hash = data.archive_file.lambda_packaged_code[each.key].output_base64sha256

  # Same for all Lambda functions
  role    = var.lambda_execution_role_arn
  runtime = "python3.12"
}


