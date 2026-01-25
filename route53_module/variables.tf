variable hosted_zone_domain_name {
  type = string
}

variable app_domain_name {
  type = string
}

variable cloudfront_distribution {
  type = object({
    domain_name    = string
    hosted_zone_id = string
  })
}
