variable "region" {
  type        = string
  description = "AWS Region"
}

#### Killswitch ####
variable "git_personal_access_token" {
  type        = string
  description = "For GitHub or GitHub Enterprise, this is the personal access token."
  sensitive   = true
}

variable "terraform_version" {
  type        = string
  description = "Version of Terraform."
}

#### S3 ####
variable "s3_bucket_name" {
  type        = string
  description = "Name of the bucket in which DAGs, Plugin and Requirements are put"
}
variable "dag_s3_path" {
  description = "Relative path of the dags folder within the source bucket"
  type        = string
  default     = "dags/"
}
variable "plugins_s3_path" {
  type        = string
  description = "relative path of the plugins.zip within the source bucket"
  default     = null
}
variable "plugins_s3_object_version" {
  default = null
}
variable "requirements_s3_path" {
  type        = string
  description = "relative path of the requirements.txt (incl. filename) within the source bucket"
  default     = null
}
variable "requirements_s3_object_version" {
  default = null
}

#### MWAA ####
variable "enabled" {
  type        = bool
  description = "Boolean flag to create the MWAA environment if set to true"
  default     = true
}

variable "environment_name" {
  type        = string
  description = "Name of the MWAA environment"
}

variable "airflow_version" {
  description = "Airflow version to be used"
  type        = string
}

variable "airflow_configuration_options" {
  description = "additional configuration to overwrite airflows standard config"
  type        = map(string)
  default     = {}
}


variable "max_workers" {
  default = "10"
}

variable "min_workers" {
  default = "1"
}

variable "environment_class" {
  default = "mw1.small"
}

variable "webserver_access_mode" {
  description = "One of: PRIVATE_ONLY, PUBLIC_ONLY"
  type        = string
  default     = null
}


variable "dag_processing_logs_enabled" {
  type    = bool
  default = true
}

variable "dag_processing_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "WARNING"
}

variable "scheduler_logs_enabled" {
  type    = bool
  default = true
}

variable "scheduler_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "WARNING"
}

variable "task_logs_enabled" {
  type    = bool
  default = true
}

variable "task_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "INFO"
}

variable "webserver_logs_enabled" {
  type    = bool
  default = true
}

variable "webserver_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "WARNING"
}

variable "worker_logs_enabled" {
  type    = bool
  default = true
}

variable "worker_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "WARNING"
}

variable "weekly_maintenance_window_start" {
  type        = string
  description = "The day and time of the week in Coordinated Universal Time (UTC) 24-hour standard time to start weekly maintenance updates of your environment in the following format: DAY:HH:MM. For example: TUE:03:30. You can specify a start time in 30 minute increments only"
  default     = "MON:01:00"
}

variable "kms_key_arn" {
  description = "KMS CMK ARN to use by MWAA for data encryption. MUST reference the same KMS key as used by S3 bucket, if the bucket uses KMS. If not specified, the default AWS owned key for MWAA will be used for backward compatibility with version 1.0.1 of this module."
  type        = string
  default     = null
}

variable "private_subnet_ids" {
  description = "Subnet Ids of the existing private subnets that should be used"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups IDs for the environment. At least one of the security group needs to allow MWAA resources to talk to each other, otherwise MWAA cannot be provisioned."
  type        = list(string)
}

#### IAM ####
variable "additional_execution_role_policy_document_json" {
  description = "Additional permissions to attach to the default mwaa execution role"
  type        = string
  default     = "{}"
}

variable "tags" {
  type    = map(string)
  default = {}
}