plugin "aws" {
    enabled = true
    version = "0.14.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
#Enables module inspection
module = true
force = false
}

# Disallow // comments in favor of #.
rule "terraform_comment_syntax" {
enabled = false
}

# Disallow variable declarations without type.
rule "terraform_typed_variables" {
enabled = true
}
 
# Disallow specifying a git or mercurial repository as a module source without pinning to a version.
rule "terraform_module_pinned_source" {
enabled = true
}
 
# Enforces naming conventions
rule "terraform_naming_convention" {
enabled = true
 
#Require specific naming structure
variable {
format = "snake_case"
}
 
locals {
format = "snake_case"
}
 
output {
format = "snake_case"
}
 
#Allow any format
resource {
format = "none"
}
 
module {
format = "none"
}
 
data {
format = "none"
}
 
}
 
# Disallow terraform declarations without require_version.
rule "terraform_required_version" {
enabled = true
}
 
# Require that all providers have version constraints through required_providers.
rule "terraform_required_providers" {
enabled = true
}
 
# Ensure that a module complies with the Terraform Standard Module Structure
rule "terraform_standard_module_structure" {
enabled = true
}