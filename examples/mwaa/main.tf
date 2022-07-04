# Copyright © 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved. This AWS Content is provided subject to the terms of the AWS Customer Agreement available at http://aws.amazon.com/agreement or other written agreement between Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both."

#### (5) Killswitch module ####
module "mwaa_killswitch" {
  source = "../../"

  git_personal_access_token = var.git_personal_access_token
  source_type               = "GIT"
  source_location           = "https://github.com/aws-samples/aws-terraform-scheduled-switch.git"
  kill_resources_schedule   = "cron(0 1/3 * * ? *)"
  revive_resources_schedule = "cron(0 1/2 * * ? *)"
  init_command              = "terraform init -chdir=examples/mwaa -input=false"
  kill_command              = "terraform apply -chdir=examples/mwaa -input=false -target=aws_mwaa_environment.this -var enabled=false -auto-approve"
  revive_command            = "terraform apply -chdir=examples/mwaa -input=false -target=aws_mwaa_environment.this -var enabled=true -auto-approve"
  terraform_version         = var.terraform_version
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# A MWAA Environment requires an IAM role (aws_iam_role), two subnets in the private zone (aws_subnet) and a versioned S3 bucket (aws_s3_bucket).

#### (1) MWAA Bucket ####
resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#### (2) MWAA Bucket Objects ####

resource "aws_s3_object" "dags" {
  for_each = fileset("${path.module}/bucket_files/dags", "*")

  bucket = aws_s3_bucket.this.id
  key    = format("dags/%s", each.value)
  source = "${path.module}/bucket_files/dags/${each.value}"
  etag   = filemd5("${path.module}/bucket_files/dags/${each.value}")
}

#### (3) IAM ####
resource "aws_iam_role" "this" {
  name               = "mwaa-${var.environment_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "this" {
  name   = "mwaa-${var.environment_name}-execution-policy"
  policy = data.aws_iam_policy_document.this.json
  role   = aws_iam_role.this.id
}

data "aws_iam_policy_document" "assume_role" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = [
        "airflow-env.amazonaws.com",
        "airflow.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "default" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "airflow:PublishMetrics"
    ]
    resources = [
      "arn:aws:airflow:${var.region}:${data.aws_caller_identity.current.account_id
      }:environment/${var.environment_name}"
    ]
  }
  statement {
    effect  = "Deny"
    actions = ["s3:ListAllMyBuckets"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:PutObject*",
      "s3:List*"
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetAccountPublicAccessBlock"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id
      }:log-group:airflow-${var.environment_name}-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }
  statement {

    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:*:airflow-celery-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    resources = var.kms_key_arn != null ? [
      var.kms_key_arn
    ] : []
    not_resources = var.kms_key_arn == null ? [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id
      }:key/*"
    ] : []
    condition {
      test = "StringLike"
      values = var.kms_key_arn != null ? [
        "sqs.${var.region}.amazonaws.com",
        "s3.${var.region}.amazonaws.com"
        ] : [
        "sqs.${var.region}.amazonaws.com"
      ]
      variable = "kms:ViaService"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::793999821937:role/sagemaker*"
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["sagemaker.amazonaws.com"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "sagemaker:*",
    ]
    not_resources = [
      "arn:aws:sagemaker:*:*:domain/*",
      "arn:aws:sagemaker:*:*:user-profile/*",
      "arn:aws:sagemaker:*:*:app/*",
      "arn:aws:sagemaker:*:*:flow-definition/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "application-autoscaling:*",
      "cloudwatch:*",
      "ec2:*",
      "ecr:*",
      "glue:*",
      "athena:*",
      "groundtruthlabeling:*",
      "iam:ListRoles",
      "kms:DescribeKey",
      "kms:ListAliases",
      "logs:*",
      "sns:ListTopics",
      "sns:Subscribe",
      "sns:CreateTopic",
      "sns:Publish",
      "tag:GetResources"
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "this" {
  source_policy_documents = [
    data.aws_iam_policy_document.default.json,
    var.additional_execution_role_policy_document_json
  ]
}

#### (4) MWAA Environment ####
resource "aws_mwaa_environment" "this" {
  count = var.enabled ? 1 : 0

  airflow_configuration_options = var.airflow_configuration_options

  execution_role_arn = aws_iam_role.this.arn
  name               = var.environment_name
  max_workers        = var.max_workers
  min_workers        = var.min_workers
  environment_class  = var.environment_class
  airflow_version    = var.airflow_version

  source_bucket_arn              = aws_s3_bucket.this.arn
  dag_s3_path                    = var.dag_s3_path

  logging_configuration {
    dag_processing_logs {
      enabled   = var.dag_processing_logs_enabled
      log_level = var.dag_processing_logs_level
    }

    scheduler_logs {
      enabled   = var.scheduler_logs_enabled
      log_level = var.scheduler_logs_level
    }

    task_logs {
      enabled   = var.task_logs_enabled
      log_level = var.task_logs_level
    }

    webserver_logs {
      enabled   = var.webserver_logs_enabled
      log_level = var.webserver_logs_level
    }

    worker_logs {
      enabled   = var.worker_logs_enabled
      log_level = var.worker_logs_level
    }
  }

  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.private_subnet_ids
  }

  webserver_access_mode           = var.webserver_access_mode
  weekly_maintenance_window_start = var.weekly_maintenance_window_start

  kms_key = var.kms_key_arn
}

