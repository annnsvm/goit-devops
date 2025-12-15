resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name
  tags   = merge(var.tags, { Name = var.bucket_name })
}

resource "aws_s3_bucket_versioning" "v" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.tfstate.id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
