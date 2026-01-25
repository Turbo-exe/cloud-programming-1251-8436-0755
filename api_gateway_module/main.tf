resource aws_apigatewayv2_api lambda_api_gateway {
  name                         = local.gateway_name
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = false
}

resource aws_cloudwatch_log_group lambda_gateway_log_group {
  name              = "/aws/lambda/${local.gateway_name}"
  retention_in_days = 7
}

resource aws_apigatewayv2_stage lambda {
  api_id      = aws_apigatewayv2_api.lambda_api_gateway.id
  name        = var.stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_gateway_log_group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    }
    )
  }
}

resource aws_apigatewayv2_integration lambda_api_gateway_integration {
  for_each = var.lambda_functions

  api_id               = aws_apigatewayv2_api.lambda_api_gateway.id
  connection_type      = "INTERNET"
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = each.value.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource aws_apigatewayv2_route lambda_api_gateway_route {
  for_each = var.lambda_functions

  api_id    = aws_apigatewayv2_api.lambda_api_gateway.id
  route_key = "${each.value.http_method} /${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_api_gateway_integration[each.key].id}"
}

resource aws_lambda_permission api_gateway {
  for_each =  var.lambda_functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api_gateway.execution_arn}/*/*"
}
