terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">=1.38.0"
    }
  }
}

provider "huaweicloud" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  project_id = var.project_id
}

data "huaweicloud_availability_zones" "test" {}

module "network_service" {
  source = "./modules/network"

  name_prefix = var.network_name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "ecs_service" {
  source = "./modules/ecs"

  image_name        = var.image_name
  name_prefix       = var.ecs_name_prefix
  az_names          = data.huaweicloud_availability_zones.test.names
  network_id        = module.network_service.network_id
  security_group_id = module.network_service.security_group_id
  admin_password    = var.ecs_admin_password
}
