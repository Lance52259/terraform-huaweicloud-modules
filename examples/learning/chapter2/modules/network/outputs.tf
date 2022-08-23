output "network_id" {
  description = "The network ID of the subnet resource for VPC service within HUAWEI Cloud"
  value       = huaweicloud_vpc_subnet.test.id
}

output "security_group_id" {
  description = "The network ID of the subnet resource for VPC service within HUAWEI Cloud"
  value       = huaweicloud_networking_secgroup.test.id
}
