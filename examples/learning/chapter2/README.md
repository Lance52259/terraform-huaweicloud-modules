# 如何构建子模块

## Module内容回顾

除[chapter1](../chapter1/README.md)所介绍的根模块外，module还由若干个子模块构成，其组成部分与根模块相似，包含资源、数据源以及声
明变量（输入变量及输出变量，如果有的话）定义的`.tf`文件。

假定此module的作用是创建ECS实例，那么该module包括但不仅限于网络模块和ECS模块，其结构如下所示：

```
huaweicloud-provider-example
|- main.tf
|- variables.tf
|- outputs.tf (Optional)
|- README.md (Optional)
|- modules
   |- network
   |  |- main.tf
   |  |- variables.tf
   |  |- outputs.tf (Optional)
   |- ecs
      |- main.tf
      |- variables.tf
      |- outputs.tf (Optional)
```

+ **main.tf**: 包含provider和资源声明。
+ **variables.tf**: 包含所有资源使用的参数。
+ **outputs.tf**: 包含所有资源导出的参数。
+ **README.md**: 此模块的详细描述（推荐每个开发者在每个模块都提供对应的描述）。
+ **network**: 网络子模块，其包含**main.tf**、**variables.tf**和**outputs.tf**（如果有的话）。
+ **ecs**: ECS子模块，其包含**main.tf**、**variables.tf**和**outputs.tf**（如果有的话）。

## 根模块main.tf

main.tf声明provider引用版本、用户鉴权以及资源使用的脚本，与[chapter1](../chapter1/README.md)不同，本章样例中的`main.tf`包含了
子模块的声明：

```
# 用于创建ECS实例的网络资源的子模块定义
module "network_service" {
  source = "./modules/network"

  name_prefix = var.network_name_prefix
  vpc_cidr    = var.vpc_cidr
}
```

module块中`source = "./modules/network"`声明了子模块的引用路径，`name_prefix`和`vpc_cidr`为网络子模块创建VPC、子网及安全组资源
所需的参数，通过输入变量的方式从根模块向子模块传递。

```
output "network_id" {
  value = huaweicloud_vpc_subnet.test.id
}
```

当网络子模块中的子网资源完成创建后将其网络ID通过输出变量的方式向根模块传递，供其调用。

```
module "ecs_service" {
  source = "./modules/ecs"

  network_id = module.network_service.network_id
  ...
}
```

根模块接收网络子模块的网络ID，传入ECS模块中用于创建ECS实例，其中引用方式为`module.{module_name}.{output_name}`。

根模块中的其他内容不多赘述，同[chapter1](../chapter1/README.md)。

## 子模块main.tf

子模块的`main.tf`与根模块的`main.tf`类似，需要声明provider的引用版本以及资源的定义，而鉴权部分可以从根模块继承而无需重复声明（如
果使用的是同一套鉴权信息的话，对于不同的鉴权信息使用或传递将在后续章节介绍）。

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

## 如何向子模块传参

上文提到了子模块在创建VPC、子网及安全组资源时需要使用到`name_prefix`和`vpc_cidr`两个变量信息，这些参数在根模块的`variables.tf`中
声明并向各子模块分配，用到的便是输入变量。

```
module "network_service" {
  source = "./modules/network"

  name_prefix = var.network_name_prefix
  ...
}
```

名为`network_service`的module块中声明于所有需要传递给子模块的变量引用，其调用的变量名称（等号右侧名称）需要在`variables.tf`中声明：

```
# 根模块的变量定义
variable "network_name_prefix" {
  description = "The name prefix for VPC resources within HUAWEI Cloud"
  value       = "..."
}
```

在根模块的`variables.tf`中声明了网络模块所使用的名称前缀，叫做`network_name_prefix`，而在子模块中出于命名规则的要求定义为
`name_prefix`。因此，在子模块的`variables.tf`中，用于接收`network_name_prefix`变量值的变量名应取为`name_prefix`。

```
# 子模块的变量定义
variable "name_prefix" {
  description = "The name prefix for VPC resources within HUAWEI Cloud"
}
```

## 如何向根模块传参

反之，当根模块需要引用到子模块资源的相关信息时，需要将子模块的值通过变量的方式向根模块传递，也就是上文提到的定义在**outputs.tf**中
的输出变量。

```
output "network_id" {
  description = "The network ID of the subnet resource for VPC service within HUAWEI Cloud"
  value       = huaweicloud_vpc_subnet.test.id
}
```

通过子模块声明的输出变量，根模块可以自由地对其进行引用：

```
module "ecs_service" {
  source = "./modules/ecs"

  network_id = module.network_service.network_id
  ...
}
```

`module.network_service.network_id`表示网络ID是由名为`network_service`的子模块中获取到。在创建ECS实例时需要很多网络相关的信息，
这些值通过诸如上述`module.xxx.xxx`的模块间变量引用或根模块`variables.tf`引用的方式实现。

以上这些内容可通过运行样例进一步理解。
