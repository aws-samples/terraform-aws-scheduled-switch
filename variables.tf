# Terraform backend variables
variable "tf_backend_bucket" {
  type        = string
  description = "S3 Backend bucket name"
}

variable "tf_backend_key" {
  type        = string
  description = "S3 object key to terraform state file"
}

# Github-Codebuild integration variables
variable "git_personal_access_token" {
  type        = string
  description = "For GitHub or GitHub Enterprise, this is the personal access token."
  sensitive   = true
  default     = null
}
variable "source_type" {
  type        = string
  description = "The type of repository that contains the source code to be built."
}

variable "source_location" {
  type        = string
  description = "Information about the location of the source code of the Terraform configuration that is being managed."
}

# CodeBuild variables

variable "switch_additional_policy_arn" {
  type        = string
  description = "ARN of additional IAM policy for CodeBuild."
  default     = null
}

# switch EventBridge variables
variable "kill_resources_schedule" {
  type        = string
  description = "Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details."
}

variable "revive_resources_schedule" {
  type        = string
  description = "Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details."
}

variable "terraform_version" {
  type        = string
  description = "Version of Terraform."
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

variable "kill_schedule_state" {
  type        = string
  description = "Whether the schedule should be enabled or disabled."
  default     = "ENABLED"
}

variable "revive_schedule_state" {
  type        = string
  description = "Whether the schedule should be enabled or disabled."
  default     = "ENABLED"
}

variable "schedule_timezone" {
  type        = string
  description = "Timezone in which the scheduling expression is evaluated."
  default     = "UTC"
}