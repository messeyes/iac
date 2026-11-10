variable "origin_id" {
  type        = string
  description = "Origin ID for the CloudFront distribution"
}

variable "bucket_domain_name" {
  type        = string
  description = "The domain name of the S3 bucket to be used as the origin for the CloudFront distribution"
}


variable "cdn_price_class" {
  type        = string
  default     = "PriceClass_200"
  description = "class of pricing for the CloudFront distribution. Options are PriceClass_100, PriceClass_200, and PriceClass_All"
}

variable "cdn_tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the CloudFront distribution"
}