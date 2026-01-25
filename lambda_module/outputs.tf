output lambda_functions {
  value = {
    for key, function in var.lambda_functions : key => {
      path          = "${var.api_path}/${function.endpoint}"
      invoke_arn    = aws_lambda_function.lambda_function[key].invoke_arn
      function_name = aws_lambda_function.lambda_function[key].function_name
      http_method   = function.http_method
    }
  }
}
