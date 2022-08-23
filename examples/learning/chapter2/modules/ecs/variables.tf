variable "image_name" {
  description = "The name of IMS image within HUAWEI Cloud"
}

variable "name_prefix" {
  description = "The name prefix for ECS resources within HUAWEI Cloud"
}

variable "network_id" {
  description = "The network ID of subnet resource within HUAWEI Cloud"
}

variable "security_group_id" {
  description = "The security group ID for the VPC service within HUAWEI Cloud"
}

variable "az_names" {
  description = "The name list of availability zone the Huaweicloud VPC"
}

variable "admin_password" {
  description = "The password of ECS instance administrator within HUAWEI Cloud"
}
