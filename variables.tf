locals {
  aws_regions = {
    us_east_1    = "us-east-1"
    eu_central_1 = "eu-central-1"
    us_west_1    = "us-west-1"
    ap_east_1    = "ap-east-1"
    af_south_1   = "af-south-1"
  }

  project = {
    name      = "cloud-programming-1251-8436-0755"
    shortcode = "cp"
  }

  # S3
  default_root_object = "home"
  static_websites = [
    {
      relative_path = "./src/websites/home-v1/index.html"
      filename      = local.default_root_object
      content_type  = "text/html"
    },
    {
      relative_path = "./src/websites/home-v1/script.js"
      filename      = "script.js"
      content_type  = "text/javascript"
    },
    {
      relative_path = "./src/websites/home-v1/styles.css"
      filename      = "styles.css"
      content_type  = "text/css"
    }
  ]

  # Lambda / API Gateway

  lambda_functions = {
    send_email = {
      endpoint       = "send-email"
      http_method    = "POST"
      relative_path  = "./src/lambda_functions/send_email"
      handler_module = "main"
      handler_method = "send_email"
    },
    list_emails = {
      endpoint       = "list-emails"
      http_method    = "POST"
      relative_path  = "./src/lambda_functions/list_emails"
      handler_module = "main"
      handler_method = "list_emails"
    }
  }

  stage_name = "prod" # This repository only supports one stage at a time.
                      # It's a best practice to have one AWS account per stage, to avoid interference between resources.


  api_path = "api"

  # Route 53
  hosted_zone_domain_name = "aws.familieasenbauer.net"
  app_domain_name         = "cloud-programming.aws.familieasenbauer.net"
}
