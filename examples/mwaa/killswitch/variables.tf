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

variable "tags" {
  type    = map(string)
  default = {}
}