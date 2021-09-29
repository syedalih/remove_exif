#create a lambda function and role

resource "aws_iam_role" "iam_lambda" {
  name = "iam_lambda"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-s3-policy"
  description = "An s3 policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "logs:*"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.tcbtestbucketa.arn}",
        "${aws_s3_bucket.tcbtestbucketa.arn}/*",
        "${aws_s3_bucket.tcbtestbucketb.arn}",
        "${aws_s3_bucket.tcbtestbucketb.arn}/*"
      ]
    }
  ]
} 
    EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = "${aws_iam_role.iam_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_lambda_function" "copytobucket" {
  filename = "copytobucket.zip"
  function_name = "copytobucket"

  source_code_hash = filebase64sha256("copytobucket.zip")

  handler = "copytobucket.lambda_handler"
  runtime = "python3.6"

  timeout = 30
  memory_size = 2048 #for big images

  role = aws_iam_role.iam_lambda.arn

  environment {
    variables = {
      DESTINATION_BUCKET = "${aws_s3_bucket.tcbtestbucketb.id}"
    }
  }
}


resource "aws_s3_bucket_notification" "s3-trigger" {
    bucket = "${aws_s3_bucket.tcbtestbucketa.id}"

    lambda_function {
        lambda_function_arn = "${aws_lambda_function.copytobucket.arn}"
        events              = ["s3:ObjectCreated:*"]
        filter_suffix       = ".jpg"
    }

    depends_on = [aws_lambda_permission.s3]
}


resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.copytobucket.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.tcbtestbucketa.arn}"
}
