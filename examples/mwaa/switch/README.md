## switch

## Usage

1. Create a Github personal access token with READ repository permissions https://doxcs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
   1. This token will be used for the CodeBuild-GitHub integration for fetching the MWAA environment Terraform IaC
2. Create an AWS Secrets Manager secret with the following name and key-value pair:
   1. Secret name: GITHUB_PERSONAL_ACCESS_TOKEN
   2. Key: TOKEN
   3. Value: {Paste the value of the token created in step 2}
3. Update the config.auto.tfvars file. Replace all values of REPLACE_ME with your s3 backend configuration used to deploy the MWAA environment.
4. Deploy the switch resources in this directory


<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mwaa_switch"></a> [mwaa\_switch](#module\_mwaa\_switch) | ../../../ | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_iam_policy.mwaa_switch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_secretsmanager_secret.github_token_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_token_secret_name"></a> [github\_token\_secret\_name](#input\_github\_token\_secret\_name) | Secrets Manager secret name that stores the GitHub personal access token. | `string` | n/a | yes |
| <a name="input_init_command"></a> [init\_command](#input\_init\_command) | Terraform command used to initialize working directory. | `string` | n/a | yes |
| <a name="input_kill_command"></a> [kill\_command](#input\_kill\_command) | Terraform command to destroy the target resources. | `string` | n/a | yes |
| <a name="input_kill_resources_schedule"></a> [kill\_resources\_schedule](#input\_kill\_resources\_schedule) | Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_revive_command"></a> [revive\_command](#input\_revive\_command) | Terraform command to revive/recreate the target resources. | `string` | n/a | yes |
| <a name="input_revive_resources_schedule"></a> [revive\_resources\_schedule](#input\_revive\_resources\_schedule) | Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details. | `string` | n/a | yes |
| <a name="input_source_location"></a> [source\_location](#input\_source\_location) | Information about the location of the source code of the Terraform configuration that is being managed. | `string` | n/a | yes |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Version of Terraform. | `string` | n/a | yes |
| <a name="input_tf_backend_bucket"></a> [tf\_backend\_bucket](#input\_tf\_backend\_bucket) | S3 Backend bucket name | `string` | n/a | yes |
| <a name="input_tf_backend_key"></a> [tf\_backend\_key](#input\_tf\_backend\_key) | S3 object key to terraform state file | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

### Outputs

No outputs.
<!-- END_TF_DOCS -->
