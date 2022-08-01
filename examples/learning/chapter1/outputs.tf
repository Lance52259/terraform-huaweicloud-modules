output "vpc_id" {
  description = "The ID of the VPC resource within HUAWEI Cloud"
  value       = huaweicloud_vpc.test.id
}

output "subnet_id" {
  description = "The ID of the subnet resource within HUAWEI Cloud"
  value       = huaweicloud_vpc_subnet.test.id
}
