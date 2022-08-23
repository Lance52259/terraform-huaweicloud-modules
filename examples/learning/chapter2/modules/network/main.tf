terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">=1.38.0"
    }
  }
}

resource "huaweicloud_vpc" "test" {
  name = format("%s-vpc", var.name_prefix)
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "test" {
  vpc_id = huaweicloud_vpc.test.id

  name        = format("%s-subnet", var.name_prefix)
  cidr        = cidrsubnet(var.vpc_cidr, 4, 1)
  gateway_ip  = cidrhost(cidrsubnet(var.vpc_cidr, 4, 1), 1)
  ipv6_enable = true
}

resource "huaweicloud_networking_secgroup" "test" {
  name                 = format("%s-secgroup", var.name_prefix)
  delete_default_rules = true
}

resource "huaweicloud_networking_secgroup_rule" "in_v4_icmp_all" {
  security_group_id = huaweicloud_networking_secgroup.test.id
  ethertype         = "IPv4"
  direction         = "ingress"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_networking_secgroup_rule" "in_v6_icmp_all" {
  security_group_id = huaweicloud_networking_secgroup.test.id
  ethertype         = "IPv6"
  direction         = "ingress"
  protocol          = "icmp"
  remote_ip_prefix  = "::/0"
}

resource "huaweicloud_networking_secgroup_rule" "in_v4_all_group" {
  security_group_id = huaweicloud_networking_secgroup.test.id
  ethertype         = "IPv4"
  direction         = "ingress"
  remote_group_id   = huaweicloud_networking_secgroup.test.id
}

resource "huaweicloud_networking_secgroup_rule" "in_v6_all_group" {
  security_group_id = huaweicloud_networking_secgroup.test.id
  ethertype         = "IPv6"
  direction         = "ingress"
  remote_group_id   = huaweicloud_networking_secgroup.test.id
}

resource "huaweicloud_networking_secgroup_rule" "out_v4_all" {
  security_group_id = huaweicloud_networking_secgroup.test.id
  ethertype         = "IPv4"
  direction         = "egress"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_networking_secgroup_rule" "out_v6_all" {
  security_group_id = huaweicloud_networking_secgroup.test.id
  ethertype         = "IPv6"
  direction         = "egress"
  remote_ip_prefix  = "::/0"
}
