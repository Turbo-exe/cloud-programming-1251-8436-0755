

output bucket_arn {
  value = aws_s3_bucket.s3_bucket.arn
  description = "S3 Bucket ARN"
}


output bucket_domain_name {
  value = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
  description = "S3 Bucket domain name"
}
