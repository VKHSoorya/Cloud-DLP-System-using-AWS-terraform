resource "aws_s3_bucket" "main_bucket" {
  bucket = var.main_bucket_name
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.secure_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.dlp_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}