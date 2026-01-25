variable project {
  type = object({
    name      = string
    shortcode = string
  })
}

variable region {
  type = string
}

variable lambda_execution_role_arn {
  type = string
}

variable api_path {
  type = string
}

variable lambda_functions {
  type = map(object({
    endpoint       = string
    http_method    = string
    relative_path  = string
    handler_module = string
    handler_method = string
  }))
}


