resource "aws_kms_key" "dlp_key" {
  description = "KMS key for DLP encryption"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "EnableRootAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "kms:*",
        Resource = "*"
      },
      {
        Sid = "AllowLambdaAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_role.arn
        },
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "dlp_alias" {
  name          = "alias/dlp-key"
  target_key_id = aws_kms_key.dlp_key.key_id
}