module api_gateway_eu_central_1 {
  source = "./api_gateway_module"
  providers = {
    aws = aws.eu_central_1
  }
  region           = local.aws_regions.eu_central_1
  project          = local.project
  lambda_functions = module.lambda_eu_central_1.lambda_functions
  stage_name       = local.stage_name
}

module api_gateway_us_west_1 {
  source = "./api_gateway_module"
  providers = {
    aws = aws.us_west_1
  }
  region           = local.aws_regions.us_west_1
  project          = local.project
  lambda_functions = module.lambda_us_west_1.lambda_functions
  stage_name       = local.stage_name
}

module api_gateway_ap_east_1 {
  source = "./api_gateway_module"
  providers = {
    aws = aws.ap_east_1
  }
  region           = local.aws_regions.ap_east_1
  project          = local.project
  lambda_functions = module.lambda_ap_east_1.lambda_functions
  stage_name       = local.stage_name
}

module api_gateway_af_south_1 {
  source = "./api_gateway_module"
  providers = {
    aws = aws.af_south_1
  }
  region           = local.aws_regions.af_south_1
  project          = local.project
  lambda_functions = module.lambda_af_south_1.lambda_functions
  stage_name       = local.stage_name
}
