source_location           = "https://github.com/aws-samples/aws-terraform-scheduled-switch.git"
kill_resources_schedule   = "cron(0 1/1 * * ? *)"
revive_resources_schedule = "cron(45 1/1 * * ? *)"
init_command              = "terraform -chdir=examples/mwaa/environment init -backend-config=\"bucket=REPLACE_ME\" -backend-config=\"key=REPLACE_ME\" -backend-config=\"region=REPLACE_ME\" -input=false" # Replace all fields of REPLACE_ME with your s3 backend configuration values that is used to deploy the MWAA environment.
kill_command              = "terraform -chdir=examples/mwaa/environment apply -input=false -target=aws_mwaa_environment.this -var enabled=false -auto-approve"
revive_command            = "terraform -chdir=examples/mwaa/environment apply -input=false -target=aws_mwaa_environment.this -var enabled=true -auto-approve"
tf_backend_bucket         = "REPLACE_ME"
tf_backend_key            = "REPLACE_ME"