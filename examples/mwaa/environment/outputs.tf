output "mwaa_environment_arn" {
  value = length(aws_mwaa_environment.this) > 0 ? aws_mwaa_environment.this[0].arn : null
}

output "mwaa_bucket_arn" {
  value = aws_s3_bucket.this.arn
}