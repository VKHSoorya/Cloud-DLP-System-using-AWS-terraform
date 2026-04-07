resource "aws_lambda_function" "dlp_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn

  handler = "lambda_function.lambda_handler"
  runtime = "python3.11"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      MAIN_BUCKET   = aws_s3_bucket.main_bucket.bucket
      SECURE_BUCKET = aws_s3_bucket.secure_bucket.bucket
      SNS_TOPIC_ARN = aws_sns_topic.dlp_topic.arn
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dlp_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.main_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.main_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.dlp_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}