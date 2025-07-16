data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source               = "./modules/vpc"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = data.aws_availability_zones.available.names
}

module "security_groups" {
  source               = "./modules/security_groups"
  vpc_id               = module.vpc.vpc_id
  my_ip                = var.my_ip
  private_subnet_cidrs = var.private_subnet_cidrs
}


module "load_balancers" {
  source               = "./modules/load_balancers"
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  public_subnets_ids   = module.vpc.public_subnet_ids
  private_subnets_ids  = module.vpc.private_subnet_ids
  proxy_sg_id          = module.security_groups.proxy_sg_id
  backend_sg_id        = module.security_groups.backend_sg_id
  internal_alb_sg_id   = module.security_groups.internal_alb_sg_id
}

module "ec2_instances" {
  source                = "./modules/ec2_instances"
  project_name          = var.project_name
  ami_id                = data.aws_ami.amazon_linux_2.id
  ssh_key_name          = var.ssh_key_name
  private_key_path      = var.private_key_path
  app_path              = var.app_path
  public_subnets_ids    = module.vpc.public_subnet_ids
  private_subnets_ids   = module.vpc.private_subnet_ids
  proxy_sg_id           = module.security_groups.proxy_sg_id
  backend_sg_id         = module.security_groups.backend_sg_id
  public_alb_tg_arn     = module.load_balancers.public_alb_tg_arn
  private_alb_tg_arn    = module.load_balancers.private_alb_tg_arn
  internal_alb_dns_name = module.load_balancers.internal_alb_dns
}

resource "local_file" "all_ips" {
  content = templatefile("${path.module}/ips.tftpl", {
    ips = module.ec2_instances.proxy_public_ips
  })
  filename = "${path.module}/all-ips.txt"
}
