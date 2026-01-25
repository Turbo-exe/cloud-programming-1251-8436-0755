variable region {
  type = string
}

variable project {
  type = object({
    name      = string
    shortcode = string
  })
}

variable lambda_functions {
  type = map(object({
    path           = string
    invoke_arn          = string
    function_name       = string
    http_method  = string
  }))
}

variable stage_name {
  type = string
}


locals {
  gateway_name   = "${var.project.shortcode}-${var.region}-gateway"
  gateway_domain_name = replace(aws_apigatewayv2_api.lambda_api_gateway.api_endpoint, "https://", "")
}

