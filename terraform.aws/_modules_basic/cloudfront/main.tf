
resource "aws_cloudfront_distribution" "sac_cloudfront_distribution" {
  enabled = true
  aliases = ["www.testingdomain.com", "testingdomain.com"]
  restrictions {
    geo_restriction {
      locations        = ["AF"]
      restriction_type = "blacklist"
    }
  }
  logging_config {
    bucket = "sac-cloudfront-bucket.s3.amazonaws.com"
  }
  origin_group {
    origin_id = "FailoverGroup"
    failover_criteria {
      status_codes = [403, 404, 500, 502]
    }
    member {
      origin_id = "failoverS3"
    }
  }
  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = aws_s3_bucket.sac_cloudfront_log_bucket.id
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  origin {
    origin_id   = aws_s3_bucket.sac_cloudfront_log_bucket.id
    domain_name = aws_s3_bucket.sac_cloudfront_log_bucket.bucket_regional_domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1"]
    }
  }
  viewer_certificate {
    acm_certificate_arn      = "acm-cert-arn"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "s3-my-webapp.example.com"
}
