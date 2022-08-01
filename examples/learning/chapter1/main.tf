terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">=1.38.0"
    }
  }
}

provider "huaweicloud" {
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  project_id  = var.project_id
}

resource "huaweicloud_vpc" "test" {
  name = var.vpc_name
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "test" {
  vpc_id = huaweicloud_vpc.test.id

  name       = var.subnet_name
  cidr       = cidrsubnet(var.vpc_cidr, 4, 1)
  gateway_ip = cidrhost(cidrsubnet(var.vpc_cidr, 4, 1), 1)
}
