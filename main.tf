# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "tfstate-remote-backend-ml-005"
    key            = "jupiter005/statefile"
    region         = "us-east-2"
    dynamodb_table = "jupiter-state-locking-ml-005"
    encrypt        = true
  }
}

module "vpc" {
  source                     = "./vpc"
  vpc_cidr_block             = var.vpc_cidr_block
  tags                       = local.project_tags
  public_subnets_cidr_block  = var.public_subnets_cidr_block
  availability_zone          = var.availability_zone
  private_subnets_cidr_block = var.private_subnets_cidr_block
  db_subnets_cidr_block      = var.db_subnets_cidr_block
}

module "auto-scaling" {
  source              = "./auto-scaling"
  public_subnet_az_2a = module.vpc.public_subnet_az_2a
  key_name            = var.key_name
  instance_type       = var.instance_type
  tags                = local.project_tags
  image_id            = var.image_id
  jupiter_app_tg_arn  = [module.alb.jupiter_app_tg_arn]
  vpc_id              = module.vpc.vpc_id
  public_subnet_az_2b = module.vpc.public_subnet_az_2b
}

module "alb" {
  source              = "./alb"
  tags                = local.project_tags
  public_subnet_az_2a = module.vpc.public_subnet_az_2a
  public_subnet_az_2b = module.vpc.public_subnet_az_2b
  vpc_id              = module.vpc.vpc_id
  ssl_policy          = var.ssl_policy
  certificate_arn     = var.certificate_arn
}

module "route53" {
  source          = "./route53"
  alb_zone_id     = module.alb.alb_zone_id
  alb_dns_name    = module.alb.alb_dns_name
  route53_zone_id = var.route53_zone_id
  domain_name     = var.domain_name
}

module "ec2" {
  source               = "./ec2"
  instance_type        = var.instance_type
  tags                 = local.project_tags
  ami_id               = var.ami_id
  public_subnet_az_2a  = module.vpc.public_subnet_az_2a
  private_subnet_az_2a = module.vpc.private_subnet_az_2a
  vpc_id               = module.vpc.vpc_id
  private_subnet_az_2b = module.vpc.private_subnet_az_2b
  key_name             = var.key_name
}

module "rds" {
  source               = "./rds"
  instance_class       = var.instance_class
  vpc_id               = module.vpc.vpc_id
  db_subnet_az_2a      = module.vpc.db_subnet_az_2a
  allocated_storage    = var.allocated_storage
  parameter_group_name = var.parameter_group_name
  db_subnet_az_2b      = module.vpc.db_subnet_az_2b
  db_name              = var.db_name
  engine               = var.engine
  tags                 = local.project_tags
  engine_version       = var.engine_version
}