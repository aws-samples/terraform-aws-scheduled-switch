# AWS
region = "ap-southeast-1"

# Networking
vpc_cidr      = "10.10.0.0/16"
pri_sub_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
pub_sub_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]

# MWAA
airflow_version       = "2.2.2"
webserver_access_mode = "PUBLIC_ONLY"
enabled               = true
environment_name      = "mwaa-example-environment"
