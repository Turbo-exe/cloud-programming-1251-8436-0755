data aws_caller_identity current {}

resource aws_s3_bucket s3_bucket {
  bucket = "${var.project.shortcode}-${var.region}-s3-bucket"
}

# Create a log bucket for S3 access logs
resource "aws_s3_bucket" "s3_access_logs" {
  bucket = "${var.project.shortcode}-${var.region}-s3-access-logs"
}

# Configure server-side encryption for the logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_logs_encryption" {
  bucket = aws_s3_bucket.s3_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable ACLs for the S3 access logs bucket
resource "aws_s3_bucket_ownership_controls" "s3_access_logs_ownership" {
  bucket = aws_s3_bucket.s3_access_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set ACL to allow S3 to write logs
resource "aws_s3_bucket_acl" "s3_access_logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_access_logs_ownership]

  bucket = aws_s3_bucket.s3_access_logs.id
  acl    = "log-delivery-write"
}

# Enable logging on the main S3 bucket
resource "aws_s3_bucket_logging" "s3_bucket_logging" {
  bucket = aws_s3_bucket.s3_bucket.id

  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "logs/"
}

# Set appropriate lifecycle rules for log rotation
resource "aws_s3_bucket_lifecycle_configuration" "s3_logs_lifecycle" {
  bucket = aws_s3_bucket.s3_access_logs.id

  rule {
    id     = "log-rotation"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource aws_s3_bucket_versioning s3_bucket_versioning {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"  # Versioning is required to use object lock, which we want to avoid accidental object deletion
  }
}

resource aws_s3_bucket_object_lock_configuration s3_bucket_lock {
  depends_on = [aws_s3_bucket_versioning.s3_bucket_versioning]

  bucket              = aws_s3_bucket.s3_bucket.id
  object_lock_enabled = "Enabled"
}


resource aws_s3_object s3_bucket_file_upload {
  # Static content is declared in a variable, allowing us to add new content without modifying IaC-Scripts
  for_each      = {for idx, site in var.static_websites : idx => site}
  bucket        = aws_s3_bucket.s3_bucket.id
  key           = each.value.filename
  source        = each.value.relative_path
  content_type  = each.value.content_type
  force_destroy = true

  # etag is an attribute on S3 holding the hash of the file.
  # We set it here, so that terraform can verify if the file needs to be reuploaded.
  etag = filemd5(each.value.relative_path)
}

# Add bucket policy to allow CloudFront OAC to access the bucket
data aws_iam_policy_document s3_bucket_policy {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [var.cloudfront_distribution_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource aws_s3_bucket_policy bucket_policy {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}
