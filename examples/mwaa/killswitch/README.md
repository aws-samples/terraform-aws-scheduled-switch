## Killswitch

## Usage

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mwaa_killswitch"></a> [mwaa\_killswitch](#module\_mwaa\_killswitch) | ../../../ | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_git_personal_access_token"></a> [git\_personal\_access\_token](#input\_git\_personal\_access\_token) | For GitHub or GitHub Enterprise, this is the personal access token. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Version of Terraform. | `string` | n/a | yes |
| <a name="input_tf_backend_bucket"></a> [tf\_backend\_bucket](#input\_tf\_backend\_bucket) | S3 Backend bucket name | `string` | n/a | yes |
| <a name="input_tf_backend_key"></a> [tf\_backend\_key](#input\_tf\_backend\_key) | S3 object key to terraform state file | `string` | n/a | yes |
| <a name="input_tf_backend_region"></a> [tf\_backend\_region](#input\_tf\_backend\_region) | AWS region where backend bucket is in | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

### Outputs

No outputs.
<!-- END_TF_DOCS -->
