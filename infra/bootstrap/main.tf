# Long lived resources the pipelines depend on. Applied once, locally, with admin credentials.
# Kept out of the main stack so manual-destroy can never delete the roles it runs under.

module "cicd_iam" {
  source = "../modules/cicd-iam"

  aws_account_id  = var.aws_account_id
  aws_region      = var.aws_region
  github_repo     = var.github_repo
  tf_state_bucket = var.tf_state_bucket
  tf_lock_table   = var.tf_lock_table
}

module "ecr" {
  source = "../modules/ecr"

  owner = var.owner
}
