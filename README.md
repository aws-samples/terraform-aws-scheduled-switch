## Scheduled switch for Terraform managed resources on AWS

This module allows you to apply a pattern of scheduled EventBridge events to manage your Terraform resources. It could be used to simply create, update or destroy resources on schedule. An example where this pattern could be applied to is when you have Terraform managed resources that are incurring costs during unutilized periods of time. Such a solution to spin resources up and down on schedule could help with significant cost savings.

## Examples

* [Amazon Managed Workflows for Apache Airflow (MWAA)](examples/mwaa/README.md)

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

## Usage

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.73.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.kill_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.revive_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.kill_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.revive_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_codebuild_project.switch_codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_source_credential.git_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_iam_policy.codebuild_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.codebuild_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.switch_codebuild_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.switch_codebuild_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.switch_codebuild_s3_backend_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.codebuild_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.codebuild_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codebuild_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_git_personal_access_token"></a> [git\_personal\_access\_token](#input\_git\_personal\_access\_token) | For GitHub or GitHub Enterprise, this is the personal access token. | `string` | n/a | yes |
| <a name="input_init_command"></a> [init\_command](#input\_init\_command) | Terraform command used to initialize working directory. | `string` | n/a | yes |
| <a name="input_kill_command"></a> [kill\_command](#input\_kill\_command) | Terraform command to destroy the target resources. | `string` | n/a | yes |
| <a name="input_kill_resources_schedule"></a> [kill\_resources\_schedule](#input\_kill\_resources\_schedule) | Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details. | `string` | n/a | yes |
| <a name="input_revive_command"></a> [revive\_command](#input\_revive\_command) | Terraform command to revive/recreate the target resources. | `string` | n/a | yes |
| <a name="input_revive_resources_schedule"></a> [revive\_resources\_schedule](#input\_revive\_resources\_schedule) | Schedule expression in the form of cron or rate expressions. Refer to https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for more details. | `string` | n/a | yes |
| <a name="input_source_location"></a> [source\_location](#input\_source\_location) | Information about the location of the source code of the Terraform configuration that is being managed. | `string` | n/a | yes |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | The type of repository that contains the source code to be built. | `string` | n/a | yes |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Version of Terraform. | `string` | n/a | yes |
| <a name="input_tf_backend_bucket"></a> [tf\_backend\_bucket](#input\_tf\_backend\_bucket) | S3 Backend bucket name | `string` | n/a | yes |
| <a name="input_tf_backend_key"></a> [tf\_backend\_key](#input\_tf\_backend\_key) | S3 object key to terraform state file | `string` | n/a | yes |
| <a name="input_kill_rule_enabled"></a> [kill\_rule\_enabled](#input\_kill\_rule\_enabled) | Whether the rule should be enabled. | `string` | `true` | no |
| <a name="input_revive_rule_enabled"></a> [revive\_rule\_enabled](#input\_revive\_rule\_enabled) | Whether the rule should be enabled. | `string` | `true` | no |

### Outputs

No outputs.
<!-- END_TF_DOCS -->
