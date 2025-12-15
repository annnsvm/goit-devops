output "bucket_id"  { value = aws_s3_bucket.tfstate.id }
output "table_name" { value = aws_dynamodb_table.locks.name }
