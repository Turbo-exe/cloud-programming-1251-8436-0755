# Send email function
module lambda_eu_central_1 {
  source = "./lambda_module"
  providers = {
    aws = aws.eu_central_1
  }
  region                    = local.aws_regions.eu_central_1
  project                   = local.project
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_path                  = local.api_path
  lambda_functions          = local.lambda_functions
}


module lambda_us_west_1 {
  source = "./lambda_module"
  providers = {
    aws = aws.us_west_1
  }
  region                    = local.aws_regions.us_west_1
  project                   = local.project
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_path                  = local.api_path
  lambda_functions          = local.lambda_functions
}

module lambda_ap_east_1 {
  source = "./lambda_module"
  providers = {
    aws = aws.ap_east_1
  }
  region                    = local.aws_regions.ap_east_1
  project                   = local.project
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_path                  = local.api_path
  lambda_functions          = local.lambda_functions
}


module lambda_af_south_1 {
  source = "./lambda_module"
  providers = {
    aws = aws.af_south_1
  }
  region                    = local.aws_regions.af_south_1
  project                   = local.project
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_path                  = local.api_path
  lambda_functions          = local.lambda_functions
}
