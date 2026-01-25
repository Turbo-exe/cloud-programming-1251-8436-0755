output distribution_arn {
  value       = aws_cloudfront_distribution.dist.arn
  description = "ARN of the CloudFront distribution"
}

output distribution_id {
  value       = aws_cloudfront_distribution.dist.id
  description = "ID of the CloudFront distribution"
}

output distribution_domain_name {
  value = aws_cloudfront_distribution.dist.domain_name
}

output distribution_hosted_zone_id {
  value = aws_cloudfront_distribution.dist.hosted_zone_id
}

output lambda_edge_edge_router_function_name {
  value = aws_lambda_function.edge_router.function_name
}

output lambda_edge_path_rewriter_function_name {
  value = aws_lambda_function.path_rewriter.function_name
}