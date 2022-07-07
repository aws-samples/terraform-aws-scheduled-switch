data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_secretsmanager_secret" "github_token_secret" {
  name = var.github_token_secret_name
}

data "aws_secretsmanager_secret_version" "github_token_secret_version" {
  secret_id = data.aws_secretsmanager_secret.github_token_secret.id
}