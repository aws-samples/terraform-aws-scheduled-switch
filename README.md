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
<!-- END_TF_DOCS -->
