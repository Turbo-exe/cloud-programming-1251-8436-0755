# Lambda execution role
resource aws_iam_role lambda_execution_role {
  provider = aws.us_east_1
  name     = "lambda_execution_role_policy_v2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Logs policy
resource aws_iam_policy lambda_logging {
  provider    = aws.us_east_1
  name        = "lambda_logging_policy_v2"
  path        = "/"
  description = "IAM policy for logging from Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# Attach logging policy to Lambda role
resource aws_iam_role_policy_attachment lambda_logs {
  provider   = aws.us_east_1
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
