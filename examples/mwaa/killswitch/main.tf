# Copyright © 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved. This AWS Content is provided subject to the terms of the AWS Customer Agreement available at http://aws.amazon.com/agreement or other written agreement between Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both."

#### (0) switch module ####
module "mwaa_switch" {
  source = "../../../"

  git_personal_access_token = jsondecode(data.aws_secretsmanager_secret_version.github_token_secret_version.secret_string)["TOKEN"]
  source_type               = "GITHUB"
  source_location           = "https://github.com/aws-samples/aws-terraform-scheduled-switch.git"
  kill_resources_schedule   = "cron(0 1/3 * * ? *)"
  revive_resources_schedule = "cron(0 1/2 * * ? *)"
  init_command              = "terraform -chdir=examples/mwaa/environment init -backend-config=\\\"bucket=${var.tf_backend_bucket}\\\" -backend-config=\\\"key=${var.tf_backend_key}\\\" -backend-config=\\\"region=${var.tf_backend_region}\\\" -input=false"
  kill_command              = "terraform -chdir=examples/mwaa/environment apply -input=false -target=aws_mwaa_environment.this -var enabled=false -auto-approve"
  revive_command            = "terraform -chdir=examples/mwaa/environment apply -input=false -target=aws_mwaa_environment.this -var enabled=true -auto-approve"
  terraform_version         = var.terraform_version
  tf_backend_bucket         = var.tf_backend_bucket
  tf_backend_key            = var.tf_backend_key
}