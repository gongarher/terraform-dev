output "ecr-key" {
    value = aws_kms_key.ecr_kms_key.arn
}

output "ecr_user_accessKey" {
  value = aws_iam_access_key.ecr_usr_accesskey.id
}

output "ecr_user_secretKey" {
  value = aws_iam_access_key.ecr_usr_accesskey.secret
  sensitive = true
}