environment directory contains MWAA infrastructure IaC that will be used to be spun up and down.

killswitch directory utilizes the killswitch root module of this repository.

# Inputs

provide git_personal_access_token, tf_backend_bucket, tf_backend_key and tf_backend_region in terraform.tfvars file before running terraform operations for the examples/mwaa/killswitch directory. Do note that it is against best practice to push this file to a repository as it contains sensitive values such as the git access token in this case.
