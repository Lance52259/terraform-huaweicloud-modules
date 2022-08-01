# 如何构建一个根模块

## 根模块简介

本章将为初次使用Terraform的开发者介绍如何构建一个根模块，包括各部分文件内容的定义和含义以及文件间的关联。

首先让我们回顾一下根模块的文件构成:

```
huaweicloud-provider-example
|- main.tf
|- variables.tf
|- outputs.tf (Optional)
|- README.md (Optional)
```

+ **main.tf**: 包含provider和资源声明。
+ **variables.tf**: 包含所有资源使用的参数。
+ **outputs.tf**: 包含所有资源导出的参数。
+ **README.md**: 此模块的详细描述（推荐每个开发者在每个模块都提供对应的描述）。

本样例以网络部署为例介绍根模块的使用。

## main.tf

首先定义一个main.tf声明provider引用版本、用户鉴权以及资源使用：

```
terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">=1.38.0"
    }
  }
}
```

此部分代码声明了脚本引用的是现网最新发布的provider，最低兼容版本为`1.38.0`，该provider在脚本中的名称为**huaweicloud**。

```
provider "huaweicloud" {
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  project_id  = var.project_id
}
```

此部分代码声明了用于华为云鉴权的四个基本参数，根据不同开发环境以及不同的region，其配置的参数使用请参考[provider介绍](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs),
注意不同provider版本间的差异：

+ **region**：资源所属的区域，如华北-北京四。
+ **access_key**：用于访问华为云控制台的Access Key ID，用于标示用户。
+ **secret_key**：Access Key ID所对应的Secret Access Key,是用户用于加密认证字符串和用来验证认证字符串的密钥。
+ **project_id**：资源所属的项目的ID。

## variables.tf

Terraform提供了两种方式在脚本中定义变量，其一为显式声明变量值:

```
variable "vpc_name" {
  description = "The name used to create the VPC resource"
  default     = "vpc-example"
}

...
```

其二为脚本执行时由用户输入：

```
variable "vpc_name" {
  description = "The name used to create the VPC resource"
}

...
```

开发者可加入自定义校验规则优化人机交互：

```
variable "vpc_name" {
  description = "The name used to create the VPC resource"

  validation {
    condition = length(regexall("^[\\w-.]{1,64}$", var.vpc_name)) > 0
    error_message = "The name can contain of 1 to 64 characters, only letters, digits, underscores (_), hyphens (-) and dots (.) are allowed."
  }
}

...
```

## outputs.tf

根模块的**outputs.tf**可缺省，该文件表示脚本应用和刷新后打印在终端上的信息：

```
output "vpc_id" {
  description = "The ID of the VPC resource within HUAWEI Cloud"
  value       = huaweicloud_vpc.test.id
}

...
```

## 关联关系

上述三个.tf文件定义了一个完整的Terraform可执行脚本，其执行顺序在Terraform中是：

+ 执行`terraform init`，根据版本和云厂商信息将provider下载到本地（**main.tf**文件中对应的terraform块和provider块的配置信息）。
+ 执行`terraform apply`，根据**variables.tf**文件定义的参数列表一一要求用户输入（如果有的话），将这些参数根据**main.tf**文件中
各资源的定义分别进行赋值，生成执行计划。
+ 确认执行`terraform apply`，根据执行计划创建资源。
+ 创建完成后根据outputs.tf文件中的出参定义，从各资源中取值并输出到终端。
