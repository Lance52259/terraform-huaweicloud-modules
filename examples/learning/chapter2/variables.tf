################################################################
###  Network

variable "network_name_prefix" {
  description = "The name prefix for VPC resources within HUAWEI Cloud"
}

variable "vpc_cidr" {
  description = "The CIDR of the Huaweicloud VPC"
  default     = "172.16.0.0/16"
}

################################################################
###  ECS

variable "image_name" {
  description = "The name of IMS image within HUAWEI Cloud"
  default     = "Ubuntu 18.04 server 64bit"
}

variable "ecs_name_prefix" {
  description = "The name prefix for ECS resources within HUAWEI Cloud"
}

variable "ecs_admin_password" {
  description = "The password of ECS instance administrator within HUAWEI Cloud"
}

################################################################
###  Authentication

variable "region" {
  description = "The region name"
  default     = "cn-north-4"
}

variable "access_key" {
  description = "The access key for authentication"
}

variable "secret_key" {
  description = "The secret key for authentication"
}

variable "project_id" {
  description = "The ID of cn-north-4 project (region)"
}
