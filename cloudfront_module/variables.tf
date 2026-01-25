variable default_root_object { type = string }

variable app_domain_name {
  type        = string
  description = "The domain name for the entire app. Should be the same across all CloudFront Distributions."
}

variable ssl_certificate_arn {
  type        = string
  description = "The ARN for the SSL certificate associated with the CloudFront distributions"
}

variable stage_name {
  type = string
}

variable api_path {
  type = string
}


variable project {
  type = object({
    name      = string
    shortcode = string
  })
}


variable origins {
  type = list(object({
    region = object({
      name      = string
      shortcode = string
    })
    failover_region = object({
      name      = string
      shortcode = string
    })

    gateway_domain_name         = string
    primary_bucket_domain_name  = string
    failover_bucket_domain_name = string
  }))
}

locals {

  tailored_origins = [
    for origin in var.origins : {
      # Copy original attributes
      region                      = origin.region
      failover_region             = origin.failover_region
      primary_bucket_domain_name  = origin.primary_bucket_domain_name
      failover_bucket_domain_name = origin.failover_bucket_domain_name
      gateway_domain_name = origin.gateway_domain_name

      # Create Group IDs
      bucket_origin_group_id = "origin-group-s3-primary-${origin.region.shortcode}-failover-${origin.failover_region.shortcode}"

      # Create origin IDs for buckets
      primary_bucket_origin_id = "origin-s3-primary-${origin.region.shortcode}"
      failover_bucket_origin_id = "origin-s3-failover-for-${origin.region.shortcode}-to-${origin.failover_region.shortcode}"

      # Create origin IDs for gateways
      gateway_origin_id = "origin-gw-primary-${origin.region.shortcode}"
    }
  ]
}
