

output gateway_domain_name {
  value = replace(aws_apigatewayv2_api.lambda_api_gateway.api_endpoint, "https://", "")
}

output gateway_id {
  value = aws_apigatewayv2_api.lambda_api_gateway.id
}
