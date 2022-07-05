output "mwaa_environment_arn" {
  value = aws_mwaa_environment.this[0].arn
}

output "mwaa_bucket_arn" {
  value = aws_s3_bucket.this.arn
}