terraform {
  source = "github.com/insight-harmony/terraform-harmony-aws-node.git?ref=${local.versions}"
}

locals {
  run = yamldecode(file(find_in_parent_folders("run.yml")))
  settings = yamldecode(file(find_in_parent_folders("settings.yml")))
  secrets = yamldecode(file(find_in_parent_folders("secrets.yml")))

  deployment_id_label_order = local.settings.deployment_id_label_order
  deployment_id = join(".", [ for i in local.deployment_id_label_order : lookup(local.run, i)])
  deployment_vars = yamldecode(file("${find_in_parent_folders("deployments")}/${local.deployment_id}.yaml"))

  ssh_profile_name = local.deployment_vars.ssh_profile_name
  ssh_profile = local.secrets.ssh_profiles[index(local.secrets.ssh_profiles.*.name, local.ssh_profile_name)]

  wallet_profile_name = local.deployment_vars.wallet_profile_name
  wallet_profile = local.secrets.wallet_profiles[index(local.secrets.wallet_profiles.*.name, local.wallet_profile_name)]

  //  credentials_profile_name = local.deployment_vars.credentials_profile
  //  credentials_profile = local.secrets.ssh_profiles[index(local.secrets.credentials_profile.*.name, local.credentials_profile_name)]

  # Imports
  versions = yamldecode(file("versions.yaml"))[local.run.environment]

  # Labels
  id_label_order = local.settings.id_label_order
  id = join("-", [ for i in local.id_label_order : lookup(local.run, i)])
  name_label_order = local.settings.name_label_order
  name = join("", [ for i in local.name_label_order : title(lookup(local.run, i))])

  tags_clouds = {
    aws = { for t in local.remote_state_path_label_order : t => lookup(local.run, t) }
  }
  tags = lookup(local.tags_clouds, local.run.provider)

  # Remote State
  remote_state_path_label_order = local.settings.remote_state_path_label_order
  remote_state_path = join("/", [ for i in local.remote_state_path_label_order : lookup(local.run, i)])
}


inputs = merge({
  vpc_name = local.id
},
local,
local.run,
local.secrets,
local.deployment_vars,
local.ssh_profile,
local.wallet_profile,
)

generate "provider" {
  path = "provider.tf"
  if_exists = "skip"
  contents =<<-EOF
provider "aws" {
  region = "${local.run.region}"
  skip_get_ec2_platforms     = true
  skip_metadata_api_check    = true
  skip_region_validation     = true
  skip_requesting_account_id = true
}

provider "cloudflare" {
  version = "~> 2.0"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt = true
    region = "us-east-1"
    key = "${local.remote_state_path}/${path_relative_to_include()}/terraform.tfstate"
    bucket = "terraform-states-${get_aws_account_id()}"
    dynamodb_table = "terraform-locks-${get_aws_account_id()}"
  }

  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

