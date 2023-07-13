# Copyright © 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved. This AWS Content is provided subject to the terms of the AWS Customer Agreement available at http://aws.amazon.com/agreement or other written agreement between Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both."

# A MWAA Environment requires an IAM role (aws_iam_role), two subnets in the private zone (aws_subnet) and a versioned S3 bucket (aws_s3_bucket).

#### (0) Networking ####

resource "aws_vpc" "mwaa_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.mwaa_vpc.id
}

resource "aws_subnet" "mwaa_private_subnets" {
  count = length(var.pri_sub_cidrs)

  vpc_id                  = aws_vpc.mwaa_vpc.id
  cidr_block              = element(var.pri_sub_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = format("mwaa-private-subnet-%s", count.index)
  }
}

resource "aws_subnet" "mwaa_public_subnets" {
  count = length(var.pub_sub_cidrs)

  vpc_id                  = aws_vpc.mwaa_vpc.id
  cidr_block              = element(var.pub_sub_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("mwaa-public-subnet-%s", count.index)
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.mwaa_vpc.id
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.pri_sub_cidrs)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id     = element(aws_subnet.mwaa_public_subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.internet_gateway]
}

resource "aws_eip" "eip" {
  count      = length(var.pri_sub_cidrs)
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

#  Routing table for private subnets
resource "aws_route_table" "private_route_tables" {
  count = length(var.pri_sub_cidrs)

  vpc_id = aws_vpc.mwaa_vpc.id
}

#  Routing table for public subnet
resource "aws_route_table" "public_route_tables" {
  count = length(var.pub_sub_cidrs)

  vpc_id = aws_vpc.mwaa_vpc.id
}

resource "aws_route" "pub_route_igw" {
  count                  = length(var.pub_sub_cidrs)
  route_table_id         = element(aws_route_table.public_route_tables.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route" "prv_route_nat" {
  count                  = length(var.pri_sub_cidrs)
  route_table_id         = element(aws_route_table.private_route_tables.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id, count.index)
}

#  Private Subnet Route table associations
resource "aws_route_table_association" "prt_associations" {
  count = length(var.pri_sub_cidrs)

  subnet_id      = element(aws_subnet.mwaa_private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_tables.*.id, count.index)
}

#  Public Subnet Route table associations
resource "aws_route_table_association" "pubrt_associations" {
  count = length(var.pub_sub_cidrs)

  subnet_id      = element(aws_subnet.mwaa_public_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.public_route_tables.*.id, count.index)
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.mwaa_vpc.id
  name   = "mwaa-no-ingress-sg"
  tags = merge({
    Name = "mwaa-no-ingress-sg"
  }, var.tags)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.mwaa_vpc.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name_prefix = "MWAAVPCFlowLogs"
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name_prefix = "VPCFlowLogRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_log_role_policy" {
  name_prefix = "VPCFlowLogRolePolicy"
  role        = aws_iam_role.vpc_flow_log_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#### (1) MWAA Bucket ####
resource "aws_s3_bucket" "this" {
  bucket_prefix = "aws-terraform-scheduled-switch-mwaa-"
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
  name_prefix        = "${var.environment_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "this" {
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

data "aws_iam_policy_document" "this" {
  source_policy_documents = [
    data.aws_iam_policy_document.default.json,
    var.additional_execution_role_policy_document_json
  ]
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

  source_bucket_arn = aws_s3_bucket.this.arn
  dag_s3_path       = var.dag_s3_path

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
    security_group_ids = [
      aws_security_group.this.id
    ]
    subnet_ids = aws_subnet.mwaa_private_subnets[*].id
  }

  webserver_access_mode           = var.webserver_access_mode
  weekly_maintenance_window_start = var.weekly_maintenance_window_start

  kms_key = var.kms_key_arn

  depends_on = [
    aws_vpc.mwaa_vpc,
    aws_subnet.mwaa_private_subnets,
    aws_subnet.mwaa_public_subnets,
    aws_route_table_association.prt_associations,
    aws_route_table_association.pubrt_associations,
    aws_route.pub_route_igw,
    aws_route.prv_route_nat,
  ]
}

