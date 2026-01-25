# Data source for the hosted zone
data aws_route53_zone main {
  name = var.hosted_zone_domain_name
}


resource aws_route53_record ipv4_rec {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.app_domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution.domain_name
    zone_id                = var.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


resource aws_route53_record ipv6_rec {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.app_domain_name
  type    = "AAAA"

  alias {
    name                   = var.cloudfront_distribution.domain_name
    zone_id                = var.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Create a CloudWatch log group for Route53 query logs
resource aws_cloudwatch_log_group route53_query_logs {
  name              = "/aws/route53/${data.aws_route53_zone.main.name}"
  retention_in_days = 7
}

# Create a resource policy to allow Route53 to write to CloudWatch Logs
resource aws_cloudwatch_log_resource_policy route53_query_logging_policy {
  policy_name     = "route53-query-logging-policy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [x
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Resource = "arn:aws:logs:*:*:log-group:/aws/route53/*"
      }
    ]
  })
}

# Enable query logging for the hosted zone
resource aws_route53_query_log main {
  depends_on = [aws_cloudwatch_log_resource_policy.route53_query_logging_policy]

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_query_logs.arn
  zone_id                  = data.aws_route53_zone.main.zone_id
}
