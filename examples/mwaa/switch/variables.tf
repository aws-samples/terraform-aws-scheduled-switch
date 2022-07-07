variable "region" {
  type        = string
  description = "AWS Region"
}

#### Terraform backend ####

variable "tf_backend_bucket" {
  type        = string
  description = "S3 Backend bucket name"
}

variable "tf_backend_key" {
  type        = string
  description = "S3 object key to terraform state file"
}

variable "tf_backend_region" {
  type        = string
  description = "AWS region where backend bucket is in"
}

#### switch ####
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