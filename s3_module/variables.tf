variable region {
  type = string
}

variable project {
  type = object({
    name      = string
    shortcode = string
  })
}

variable cloudfront_distribution_arn {
  type        = string
  description = "ARN of the CloudFront distribution that will access this bucket"
}


variable static_websites {
  type = list(object({
    relative_path = string
    filename      = string
    content_type  = string
  }))
}
