# IAM role for Lambda@Edge
resource "aws_iam_role" "lambda_edge_role" {
  name = "lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

# IAM policy for Lambda@Edge basic execution
resource aws_iam_role_policy_attachment lambda_edge_basic {
  role       = aws_iam_role.lambda_edge_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Edge Router function
data archive_file edge_router {
  type        = "zip"
  source_file = "${path.module}/edge_router.py"
  output_path = "build/edge_router.zip"
}

resource aws_lambda_function edge_router {
  filename         = data.archive_file.edge_router.output_path
  function_name    = "edge-router-v2"   # We need to version the function name for redeployments, as AWS does not
  # provide a way for terraform to destroy Lambda@Edge functions. Therefore
  # we simply create a new one without destroying the old one.
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "edge_router.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.edge_router.output_base64sha256
  publish          = true
  memory_size      = 128
  timeout          = 5
}

# Path rewriter function
data archive_file path_rewriter {
  type        = "zip"
  source_file = "${path.module}/path_rewriter.py"
  output_path = "build/path_rewriter.zip"
}

resource aws_lambda_function path_rewriter {
  filename         = data.archive_file.path_rewriter.output_path
  function_name    = "path-rewriter-v2"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "path_rewriter.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.path_rewriter.output_base64sha256
  publish          = true
  memory_size      = 128
  timeout          = 5
}

# CloudWatch log groups for Lambda@Edge functions
# Lambda@Edge functions automatically create CloudWatch log groups in each AWS region where the functions are executed
# We explicitly define these log groups to control retention periods

# for edge-router
resource aws_cloudwatch_log_group edge_router_logs {
  for_each          = { for i, origin in var.origins : i => origin }
  name              = "/aws/lambda/${each.value.region.name}.${aws_lambda_function.edge_router.function_name}"
  retention_in_days = 7
}

# for path-rewriter
resource aws_cloudwatch_log_group path_rewriter_logs {
  for_each          = { for i, origin in var.origins : i => origin }
  name              = "/aws/lambda/${each.value.region.name}.${aws_lambda_function.path_rewriter.function_name}"
  retention_in_days = 7
}
