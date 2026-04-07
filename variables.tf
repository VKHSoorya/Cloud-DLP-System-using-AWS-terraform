variable "aws_region" {}
variable "main_bucket_name" {}
variable "secure_bucket_name" {}
variable "lambda_function_name" {}
variable "sns_topic_name" {}

variable "subscription_email" {
  description = "Email address for SNS subscription"
  type        = string
}
