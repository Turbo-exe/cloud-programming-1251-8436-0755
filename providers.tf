terraform {
  required_version = "= 1.14.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.25.0"
    }
  }
}

provider aws {
  alias   = "us_east_1"
  region  = local.aws_regions.us_east_1
  profile = "cloud-programming"

  default_tags {
    tags = {
      project_name = local.project.name
    }
  }
}

provider aws {
  alias   = "eu_central_1"
  region  = local.aws_regions.eu_central_1
  profile = "cloud-programming"

  default_tags {
    tags = {
      project_name = local.project.name
    }
  }
}

provider aws {
  alias   = "us_west_1"
  region  = local.aws_regions.us_west_1
  profile = "cloud-programming"

  default_tags {
    tags = {
      project_name = local.project.name
    }
  }
}

provider aws {
  alias   = "ap_east_1"
  region  = local.aws_regions.ap_east_1
  profile = "cloud-programming"

  default_tags {
    tags = {
      project_name = local.project.name
    }
  }
}

provider aws {
  alias   = "af_south_1"
  region  = local.aws_regions.af_south_1
  profile = "cloud-programming"

  default_tags {
    tags = {
      project_name = local.project.name
    }
  }
}

