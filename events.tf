resource "aws_scheduler_schedule" "kill_schedule" {
  name_prefix = "KillEvent-"
  state       = var.kill_schedule_state

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.kill_resources_schedule
  schedule_expression_timezone = var.schedule_timezone

  target {
    arn      = aws_codebuild_project.switch_codebuild_project.arn
    role_arn = aws_iam_role.codebuild_role.arn

    input = <<DOC
{
  "environmentVariablesOverride": [
    {
      "name": "TF_INIT_COMMAND_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_init_parameter.name}"
    },
    {
      "name": "TF_APPLY_COMMAND_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_kill_parameter.name}"
    },
    {
      "name": "TERRAFORM_VERSION_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_version_parameter.name}"
    }
  ]
}
DOC

  }
}

resource "aws_scheduler_schedule" "revive_schedule" {
  name_prefix = "ReviveEvent-"
  state       = var.revive_schedule_state

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.revive_resources_schedule
  schedule_expression_timezone = var.schedule_timezone

  target {
    arn      = aws_codebuild_project.switch_codebuild_project.arn
    role_arn = aws_iam_role.codebuild_role.arn

    input = <<DOC
{
  "environmentVariablesOverride": [
    {
      "name": "TF_INIT_COMMAND_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_init_parameter.name}"
    },
    {
      "name": "TF_APPLY_COMMAND_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_revive_parameter.name}"
    },
    {
      "name": "TERRAFORM_VERSION_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_version_parameter.name}"
    }
  ]
}
DOC

  }
}

data "aws_iam_policy_document" "codebuild_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.switch_codebuild_project.arn]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name_prefix        = "StartSwitchRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_trust.json
}

resource "aws_iam_policy" "codebuild_policy" {
  name_prefix = "StartSwitchPolicy"
  policy      = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_role_policy_attachment" "codebuild_attachment" {
  policy_arn = aws_iam_policy.codebuild_policy.arn
  role       = aws_iam_role.codebuild_role.name
}