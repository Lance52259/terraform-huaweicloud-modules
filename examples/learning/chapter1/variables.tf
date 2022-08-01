variable "vpc_name" {
  description = "The name used to create the VPC resource"

  validation {
    condition = length(regexall("^[\\w-.]{1,64}$", var.vpc_name)) > 0
    error_message = "The name can contain of 1 to 64 characters, only letters, digits, underscores (_), hyphens (-) and dots (.) are allowed."
  }
}

variable "vpc_cidr" {
  description = "The CIDR used to create the VPC network"
  default     = "192.168.0.0/16"
}

variable "subnet_name" {
  description = "The name used to create the subnet resource"

  validation {
    condition = length(regexall("^[\\w-.]{1,64}$", var.vpc_name)) > 0
    error_message = "The name can contain of 1 to 64 characters, only letters, digits, underscores (_), hyphens (-) and dots (.) are allowed."
  }
}

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
