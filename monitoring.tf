# CloudWatch Dashboards and Alarms

# Create an SNS topic for alerts
resource aws_sns_topic alerts {
  name = "${local.project.shortcode}-alerts"  # For the purposes of this project we don't configure any delivery policies.
}

# Create CloudWatch dashboard for monitoring
resource aws_cloudwatch_dashboard main_dashboard {
  dashboard_name = "${local.project.shortcode}-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", module.cloudfront_distribution.distribution_id]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "CloudFront Requests"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudFront", "4xxErrorRate", "DistributionId", module.cloudfront_distribution.distribution_id],
            ["AWS/CloudFront", "5xxErrorRate", "DistributionId", module.cloudfront_distribution.distribution_id]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "CloudFront Error Rates"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", module.cloudfront_distribution.lambda_edge_edge_router_function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", module.cloudfront_distribution.lambda_edge_path_rewriter_function_name]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Lambda@Edge Invocations"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", module.cloudfront_distribution.lambda_edge_edge_router_function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.cloudfront_distribution.lambda_edge_path_rewriter_function_name]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Lambda@Edge Errors"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", module.api_gateway_eu_central_1.gateway_id],
            ["AWS/ApiGateway", "Count", "ApiId", module.api_gateway_us_west_1.gateway_id],
            ["AWS/ApiGateway", "Count", "ApiId", module.api_gateway_ap_east_1.gateway_id],
            ["AWS/ApiGateway", "Count", "ApiId", module.api_gateway_af_south_1.gateway_id]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "API Gateway Requests"
        }
      }
    ]
  })
}

# Create alarms for critical metrics
resource aws_cloudwatch_metric_alarm cloudfront_5xx_errors {
  alarm_name          = "${local.project.shortcode}-cloudfront-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "This alarm monitors CloudFront 5xx error rate"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    DistributionId = module.cloudfront_distribution.distribution_id
  }
}

resource aws_cloudwatch_metric_alarm lambda_edge_errors {
  alarm_name          = "${local.project.shortcode}-lambda-edge-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This alarm monitors Lambda@Edge errors"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    FunctionName = "edge-router-v2"
  }
}

resource aws_cloudwatch_metric_alarm api_gateway_5xx_errors {
  for_each = {
    eu = module.api_gateway_eu_central_1.gateway_id,
    us = module.api_gateway_us_west_1.gateway_id,
    ap = module.api_gateway_ap_east_1.gateway_id,
    af = module.api_gateway_af_south_1.gateway_id
  }
  
  alarm_name          = "${local.project.shortcode}-api-gateway-5xx-errors-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This alarm monitors API Gateway 5xx errors for ${each.key} region"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    ApiId = each.value
  }
}