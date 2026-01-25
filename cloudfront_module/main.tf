resource aws_cloudfront_origin_access_control s3 {
  name                              = "default-oac-s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Create a new S3 bucket for CloudFront logs
resource aws_s3_bucket cloudfront_logs {
  bucket = "${var.project.name}-cloudfront-logs"
}

# Configure server-side encryption for the logs bucket
resource aws_s3_bucket_server_side_encryption_configuration cloudfront_logs_encryption {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable ACLs for the CloudFront logs bucket
resource aws_s3_bucket_ownership_controls cloudfront_logs_ownership {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set ACL to allow CloudFront to write logs
resource aws_s3_bucket_acl cloudfront_logs_acl {
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs_ownership]

  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "log-delivery-write"
}

# Set appropriate lifecycle rules for log rotation
resource aws_s3_bucket_lifecycle_configuration cloudfront_logs_lifecycle {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    id     = "log-rotation"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource aws_cloudfront_distribution dist {

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  aliases = [var.app_domain_name]
  retain_on_delete = true   # Useful for this project to reduce terraform destroy times

  price_class = "PriceClass_200"  # https://aws.amazon.com/de/cloudfront/pricing/

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations = ["GB"]   # Blacklists Great Britain for easy testing e.g. via VPN
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.ssl_certificate_arn
    ssl_support_method  = "sni-only"
  }


  # S3 Origin Groups
  dynamic origin_group {
    for_each = toset(local.tailored_origins)
    iterator = tailored_origin

    content {
      origin_id = tailored_origin.value.bucket_origin_group_id

      member { origin_id = tailored_origin.value.primary_bucket_origin_id }
      member { origin_id = tailored_origin.value.failover_bucket_origin_id }

      failover_criteria {
        status_codes = [500, 503, 504]
      }
    }
  }


  # API Gateway Origin
  # CloudFront does not support origin groups (failovers) for POST methods (as used by most backend features)
  # Therefore we can't put our API Gateway origin into an origin group.
  dynamic origin {
    for_each = toset(local.tailored_origins)
    iterator = tailored_origin

    content {
      domain_name = tailored_origin.value.gateway_domain_name
      origin_id   = tailored_origin.value.gateway_origin_id

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols = ["TLSv1.2"]
      }
    }
  }


  # S3 Origins
  # Primary
  dynamic origin {
    for_each = toset(local.tailored_origins)
    iterator = tailored_origin

    content {
      # One can use OAC or OAI to use S3 as an CloudFront origin
      # As per this blog article (https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
      # it is encouraged to use OAC, therefore we use it here.
      origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
      domain_name              = tailored_origin.value.primary_bucket_domain_name
      origin_id                = tailored_origin.value.primary_bucket_origin_id
    }
  }

  # Failover
  dynamic origin {
    for_each = toset(local.tailored_origins)
    iterator = tailored_origin

    content {
      origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
      domain_name              = tailored_origin.value.failover_bucket_domain_name
      origin_id                = tailored_origin.value.failover_bucket_origin_id
    }
  }


  # Default cache behavior - this applies when no ordered cache behaviour (below) matches
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id       = local.tailored_origins[0].bucket_origin_group_id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      headers = [
        "CloudFront-Viewer-Country"
      ]
      cookies {
        forward = "none"
      }
    }

    # Associate Lambda@Edge function with origin-request event, which rewrites users url to use closest source
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.edge_router.qualified_arn
      include_body = false
    }
  }


  # Cache behaviors for each gateway
  dynamic ordered_cache_behavior {
    for_each = toset(local.tailored_origins)
    iterator = gateway_origin

    content {
      path_pattern     = "${gateway_origin.value.region.shortcode}/${var.stage_name}/${var.api_path}/*"
      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods = ["GET", "HEAD"]
      target_origin_id = gateway_origin.value.gateway_origin_id

      forwarded_values {
        query_string = true           # For API usages, we of course need the query parameters
        headers = ["Authorization"]   # and this header is just for demonstration, what a typical API may need
        cookies {
          forward = "all"
        }
      }

      # The Path Rewriter function removes the regional prefix (e.g. /eu) before passing the request to the origin
      lambda_function_association {
        event_type   = "origin-request"
        lambda_arn   = aws_lambda_function.path_rewriter.qualified_arn
        include_body = false
      }


      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
  }


  # Cache behaviors for each S3 bucket
  dynamic ordered_cache_behavior {
    for_each = toset(local.tailored_origins)
    iterator = tailored_origin

    content {
      path_pattern     = "${tailored_origin.value.region.shortcode}/*"
      allowed_methods = ["HEAD", "GET"]
      cached_methods = ["HEAD", "GET"]
      target_origin_id = tailored_origin.value.bucket_origin_group_id

      forwarded_values {
        query_string = false
        cookies {
          forward = "none"
        }
      }

      # The Path Rewriter function removes the regional prefix (e.g. /eu) before passing the request to the origin
      lambda_function_association {
        event_type   = "origin-request"
        lambda_arn   = aws_lambda_function.path_rewriter.qualified_arn
        include_body = false
      }

      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
  }

}
