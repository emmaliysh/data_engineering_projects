#################################
# Outputs
#################################
output "raw_bucket" {
  value = aws_s3_bucket.raw.bucket
}

output "curated_bucket" {
  value = aws_s3_bucket.curated.bucket
}

output "athena_workgroup" {
  value = aws_athena_workgroup.analytics.name
}