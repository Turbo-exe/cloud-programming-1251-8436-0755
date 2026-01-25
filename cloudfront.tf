module cloudfront_distribution {
  # Primary EU; Secondary US
  depends_on = [aws_acm_certificate.cert, aws_acm_certificate_validation.cert]
  source = "./cloudfront_module"
  providers = {
    aws = aws.us_east_1
  }
  stage_name = local.stage_name

  origins = [
    {
      region = {
        name      = "eu-central-1",
        shortcode = "eu"
      }
      failover_region = {
        name      = "eu-central-1",
        shortcode = "eu"
      }
      gateway_domain_name         = module.api_gateway_eu_central_1.gateway_domain_name
      primary_bucket_domain_name  = module.s3_eu_central_1.bucket_domain_name
      failover_bucket_domain_name = module.s3_us_west_1.bucket_domain_name
    },
    {
      region = {
        name      = "us-west-1",
        shortcode = "us"
      }
      failover_region = {
        name      = "eu-central-1",
        shortcode = "eu"
      }
      gateway_domain_name         = module.api_gateway_us_west_1.gateway_domain_name
      primary_bucket_domain_name  = module.s3_us_west_1.bucket_domain_name
      failover_bucket_domain_name = module.s3_eu_central_1.bucket_domain_name
    },
    {
      region = {
        name      = "ap-east-1",
        shortcode = "ap"
      }
      failover_region = {
        name      = "af-south-1"
        shortcode = "af"
      }
      gateway_domain_name         = module.api_gateway_ap_east_1.gateway_domain_name
      primary_bucket_domain_name  = module.s3_ap_east_1.bucket_domain_name
      failover_bucket_domain_name = module.s3_af_south_1.bucket_domain_name
    },
    {
      region = {
        name      = "af-south-1",
        shortcode = "af"
      }
      failover_region = {
        name      = "ap-east-1"
        shortcode = "ap"
      }
      gateway_domain_name         = module.api_gateway_af_south_1.gateway_domain_name
      primary_bucket_domain_name  = module.s3_af_south_1.bucket_domain_name
      failover_bucket_domain_name = module.s3_ap_east_1.bucket_domain_name
    }
  ]
  default_root_object = local.default_root_object
  app_domain_name     = local.app_domain_name
  api_path            = local.api_path
  project             = local.project
  ssl_certificate_arn = aws_acm_certificate.cert.arn
}
