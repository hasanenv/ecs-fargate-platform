module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  owner                = var.owner
}

module "iam" {
  source = "./modules/iam"

  cicd_role_name = "hasanenv-cd-role-ecs"
  github_repo    = var.github_repo
  aws_account_id = var.aws_account_id
  owner          = var.owner
}

module "ecr" {
  source = "./modules/ecr"

  owner = var.owner
}

module "security_groups" {
  source = "./modules/security-groups"

  vpc_id = module.vpc.vpc_id
  owner  = var.owner
}

module "acm" {
  source = "./modules/acm"

  domain_name = "hasangatus.click"
  zone_id     = data.aws_route53_zone.hasangatus.zone_id
  owner       = var.owner
}

module "alb" {
  source = "./modules/alb"

  security_group_id   = module.security_groups.alb_security_group_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  vpc_id              = module.vpc.vpc_id
  acm_certificate_arn = module.acm.certificate_arn
  owner               = var.owner
}

module "route_53" {
  source = "./modules/route53"

  zone_id      = data.aws_route53_zone.hasangatus.zone_id
  zone_name    = data.aws_route53_zone.hasangatus.name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "ecs" {
  source = "./modules/ecs"

  ecr_registry                = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  ecr_repo                    = "gatus-repo"
  alb_target_group_arn        = module.alb.alb_target_group_arn
  ecs_service_sg_id           = module.security_groups.ecs_service_sg_id
  aws_region                  = var.aws_region
  private_subnet_ids          = module.vpc.private_subnet_ids
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  gatus_config_ssm_arn        = aws_ssm_parameter.gatus_config.arn
  owner                       = var.owner
}