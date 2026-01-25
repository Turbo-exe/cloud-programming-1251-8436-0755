module s3_eu_central_1 {
  source = "./s3_module"
  providers = {
    aws = aws.eu_central_1
  }
  region                      = local.aws_regions.eu_central_1
  project                     = local.project
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
  static_websites             = local.static_websites
}


module s3_us_west_1 {
  source = "./s3_module"
  providers = {
    aws = aws.us_west_1
  }
  region                      = local.aws_regions.us_west_1
  project                     = local.project
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
  static_websites             = local.static_websites
}


module s3_ap_east_1 {
  source = "./s3_module"
  providers = {
    aws = aws.ap_east_1
  }
  region                      = local.aws_regions.ap_east_1
  project                     = local.project
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
  static_websites             = local.static_websites
}


module s3_af_south_1 {
  source = "./s3_module"
  providers = {
    aws = aws.af_south_1
  }
  region                      = local.aws_regions.af_south_1
  project                     = local.project
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
  static_websites             = local.static_websites
}
