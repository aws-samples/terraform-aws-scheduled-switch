variable "region" {
  type        = string
  description = "AWS Region"
}

#### switch ####

variable "tf_backend_bucket" {
  type        = string
  description = "S3 Backend bucket name"
}

variable "tf_backend_key" {
  type        = string
  description = "S3 object key to terraform state file"
}

variable "source_location" {
  type        = string
  description = "Information about the location of the source code of the Terraform configuration that is being managed."
}

variable "kill_resources_schedule" {
  type        = string
  description = "Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details."
}

variable "revive_resources_schedule" {
  type        = string
  description = "Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details."
}

variable "init_command" {
  type        = string
  description = "Terraform command used to initialize working directory."
}

variable "kill_command" {
  type        = string
  description = "Terraform command to destroy the target resources."
}

variable "revive_command" {
  type        = string
  description = "Terraform command to revive/recreate the target resources."
}

variable "github_token_secret_name" {
  type        = string
  description = "Secrets Manager secret name that stores the GitHub personal access token."
}

variable "terraform_version" {
  type        = string
  description = "Version of Terraform."
}

variable "tags" {
  type    = map(string)
  default = {}
}