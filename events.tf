resource "aws_cloudwatch_event_rule" "kill_rule" {
  name        = "KillEvent"
  description = "Scheduled event to kill resources."

  schedule_expression = var.kill_resources_schedule

}

resource "aws_cloudwatch_event_rule" "revive_rule" {
  name        = "ReviveEvent"
  description = "Scheduled event to revive resources."

  schedule_expression = var.revive_resources_schedule

}

resource "aws_cloudwatch_event_target" "kill_resources" {
  target_id = "KillResources"
  arn       = aws_codebuild_project.killswitch_codebuild_project.arn
  input     = <<DOC
{
  "environmentVariablesOverride": [
    {
      "name": "TF_INIT_COMMAND",
      "type": "PLAINTEXT",
      "value": "${var.init_command}"
    },
    {
      "name": "TF_APPLY_COMMAND",
      "type": "PLAINTEXT",
      "value": "${var.kill_command}"
    },
    {
      "name": "TERRAFORM_VERSION",
      "type": "PLAINTEXT",
      "value": "${var.terraform_version}"
    }
  ]
}
DOC
  rule      = aws_cloudwatch_event_rule.kill_rule.name
  role_arn  = aws_iam_role.codebuild_role.arn

}

resource "aws_cloudwatch_event_target" "revive_resources" {
  target_id = "ReviveResources"
  arn       = aws_codebuild_project.killswitch_codebuild_project.arn
  input     = <<DOC
{
  "environmentVariablesOverride": [
    {
      "name": "TF_INIT_COMMAND",
      "type": "PLAINTEXT",
      "value": "${var.init_command}"
    },
    {
      "name": "TF_APPLY_COMMAND",
      "type": "PLAINTEXT",
      "value": "${var.revive_command}"
    },
    {
      "name": "TERRAFORM_VERSION",
      "type": "PLAINTEXT",
      "value": "${var.terraform_version}"
    }
  ]
}
DOC
  rule      = aws_cloudwatch_event_rule.revive_rule.name
  role_arn  = aws_iam_role.codebuild_role.arn

}

data "aws_iam_policy_document" "codebuild_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.killswitch_codebuild_project.arn]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name_prefix               = "StartKillSwitchRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_trust.json
}

resource "aws_iam_policy" "codebuild_policy" {
  name_prefix   = "StartKillSwitchPolicy"
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_role_policy_attachment" "codebuild_attachment" {
  policy_arn = aws_iam_policy.codebuild_policy.arn
  role       = aws_iam_role.codebuild_role.name
}