output "bucket_domain_name" {
  value = data.aws_s3_bucket.s3_bucket.bucket_domain_name
  sensitive = false
  description = "The name of the S3 bucket"
}

output "bucket_region" {
  value = data.aws_s3_bucket.s3_bucket.region
  sensitive = false
  description = "The region of the S3 bucket"
}