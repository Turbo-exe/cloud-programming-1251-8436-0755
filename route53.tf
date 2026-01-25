module route53 {
  source = "./route53_module"
  providers = {
    aws = aws.us_east_1   # Route53 is a global service, therefore we configure it in us-east-1
  }
  app_domain_name         = local.app_domain_name
  hosted_zone_domain_name = local.hosted_zone_domain_name
  cloudfront_distribution = {
    domain_name    = module.cloudfront_distribution.distribution_domain_name
    hosted_zone_id = module.cloudfront_distribution.distribution_hosted_zone_id
  }
}
