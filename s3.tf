resource "aws_s3_bucket" "tcbtestbucketa" {
  bucket = "tcbtestbucketa"
  acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "tcbtestbucketb" {
  bucket = "tcbtestbucketb"
  acl = "private"
  force_destroy = true
}