output "bucket_domain_name" {
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
  sensitive   = false
  description = "The name of the S3 bucket"
}

output "bucket_id" {
  value       = data.aws_s3_bucket.bucket.id
  sensitive   = false
  description = "The ID of the S3 bucket"
}