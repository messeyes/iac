variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to be created"
}

variable "s3_tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the S3 bucket"
}