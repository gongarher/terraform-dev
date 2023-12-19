#################
#  Private ECR  #
#################
resource "aws_ecr_repository" "ecr" {
  depends_on = [aws_kms_key.ecr_kms_key]
  name                 = var.ecr_name
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_kms_key.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

#########
#  KMS  #
#########
resource "aws_kms_key" "ecr_kms_key" {
  description             = "test-ecr-key"
  deletion_window_in_days = 7 # minimun period

  tags = var.tags
}

######################
#  Specific ECR usr  #
######################
resource "aws_iam_user" "ecr_usr" {
  name = "${aws_ecr_repository.ecr.registry_id}-usr"

}

resource "aws_iam_access_key" "ecr_usr_accesskey" {
  user = aws_iam_user.ecr_usr.name
}

resource "aws_iam_policy" "ecr_usr_policy" {
  name = "${aws_iam_user.ecr_usr.name}-policy"
  path = "/"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:*"
        ],
        "Resource": ["${aws_ecr_repository.ecr.arn}"]
      },
      {
        "Effect": "Allow",
        "Action": [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:Describe*"
        ],
        "Resource": ["${aws_kms_key.ecr_kms_key.arn}"]
      }
    ]
  })
}

# attach policy to user
resource "aws_iam_user_policy_attachment" "ecr_usr" {
  user       = aws_iam_user.ecr_usr.name
  policy_arn = aws_iam_policy.ecr_usr_policy.arn
}
