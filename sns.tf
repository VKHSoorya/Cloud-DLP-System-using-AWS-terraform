resource "aws_sns_topic" "dlp_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.dlp_topic.arn
  protocol  = "email"
  endpoint  = var.subscription_email
}