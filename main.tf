resource "aws_codebuild_source_credential" "git_credentials" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.git_personal_access_token
}
resource "aws_codebuild_project" "switch_codebuild_project" {
  name                   = "terraform-switch-codebuild"
  description            = "CodeBuild project that behaves as a switch for Terraform resources."
  build_timeout          = "60"
  service_role           = aws_iam_role.switch_codebuild_role.arn
  concurrent_build_limit = 1
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "switch-codebuild-log-group"
      stream_name = "switch-codebuild-log-stream"
    }
  }

  source {
    type            = var.source_type
    location        = var.source_location
    git_clone_depth = 1
    buildspec       = file("${path.module}/buildspec.yaml")
  }


  tags = {}
}

resource "aws_iam_role" "switch_codebuild_role" {
  name_prefix = "switch-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "switch_codebuild_s3_backend_policy" {
  role = aws_iam_role.switch_codebuild_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.tf_backend_bucket}"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::${var.tf_backend_bucket}/${var.tf_backend_key}"
    }
  ]
}

POLICY  
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.switch_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "switch_additional_policy" {
  role       = aws_iam_role.switch_codebuild_role.name
  policy_arn = var.switch_additional_policy_arn
}