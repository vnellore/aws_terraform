resource "aws_s3_bucket" "my-ui-bucket" {
  bucket = "${var.my_ui_bucket_name}"
  acl    = "public-read"

  versioning {
    enabled = false
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    name = "${var.my_ui_bucket_name}"
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.my_ui_bucket_name}/*"]
    }
  ]
}
POLICY
}
