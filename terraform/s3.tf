/** Where contact form submissions are permanently stored as JSON files */
resource "aws_s3_bucket" "contacts" {
  bucket        = "${local.name_prefix}-contacts"
  force_destroy = true
  tags          = local.common_tags
}

/** File is encrytped at rest (AES256) so external users can't read the files without the key managed by AWS */
resource "aws_s3_bucket_server_side_encryption_configuration" "contacts" {
  bucket = aws_s3_bucket.contacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
