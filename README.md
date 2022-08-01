# terraform-huaweicloud-modules

本仓库提供多套[**Terraform**](https://www.terraform.io/language)模板供开发者在其脚本中调用，其使用详情见各模块**README.md**
文件。此外本仓库还提供了供初学者学习了解华为云资源、模块的[资料](examples/learning/README.md)，欢迎各位初学者前来学习以及欢迎各位开发者
向本仓库贡献modules代码和样例。

## Module基本介绍

模块是可以同时使用多个资源的容器，由目录中多个保存在一起的`.tf`或`.tf.json`文件中定义的资源组成。
模块是实现Terraform包装和重用资源配置的重要方式。

## 模块分类

模块主要分为两类:

+ **根模块**：每个Terraform配置中都至少有一个模块，称之为根模块，该模块由主工作目录中的`.tf`或
  `.tf.json`文件中定义的各个资源组成。
+ **子模块**：在子目录中定义的被另一个模块调用的模块，称为子模块，该模块由当前子模块目录中的`.tf`或
  `.tf.json`文件中定义的各个资源组成。子模块可以在同一个配置中多次调用，同样多个配置也可以共用一个子模块。

## 模块结构

一个项目通常由上述两种类型的模块构成，如构建一个CCE集群需要使用到网络模块和CCE模块，其中CCE模块对网络模块创建的VPC和子网具有依赖
性，因此其结构为:

```
huaweicloud-provider-example
|- main.tf
|- variables.tf
|- outputs.tf
|- modules
   |- network-example
   |  |- main.tf
   |  |- varibales.tf
   |  |- outputs.tf
   |- cce-example
      |- main.tf
      |- varibales.tf
      |- outputs.tf
```

## 模块声明

module块描述了父模块调用子模块的语法，其样例如下:

```hcl
module "cce" {
  source = "./modules/cce-example"

  vpc_id            = module.network.vpc_id
  network_id        = module.network.network_id
  security_group_id = module.network.security_group_id
}
```

module关键字代表声明对子模块的调用，关键字后面的标签是一个本地使用的名称，通过引用这个名称来引用这个模块的资源属性。在模块声明主体
中（`{`和`}`之间）的是模块的参数，包含：**source**、**version**、**inputs** 和**meta-arguments**，其约束如下:

+ **source**参数在所有模块中都强制要求赋予。
+ 建议对Hashicorp官方发布的模块使用version参数控制引用版本。
+ 依赖于其他模块的资源参数都应该定义与**inputs**中，如上述示例中的**vpc_id**、**network_id**和**security_group_id**。
+ 元参数适用于所有模块。

### source

所有的模块都需要一个`source`参数，这是一个由Terraform定义的元参数。它的值要么对应本地的模块配置路径，要么是可供下载使用的远程模块
源（该值不允许使用表达式）。可以在多个模块中指定相同的源地址，以创建其中定义的资源的多个副本，可以赋予不同的变量值。

-> 添加、删除或修改模块后，必须重新运行`terraform init`，以便Terraform对其进行调整。默认情况下，此命令不会升级已安装模块的版本，
需要使用`-upgrade`升级到最新版本。

### version

在使用各厂商在Hashicorp上发布的模块时，建议显式地声明可接受的版本号，以免产生因版本变化而导致的不必要变更。如使用AWS发布的consul模
块，我们可以指定使用版本为`0.0.5`。

```
module "consul" {
  source  = "hashicorp/consul/aws"
  version = "0.0.5"

  servers = 3
}
```

version参数接受一个用于约束版本的字符串，配置此参数后terraform将使用符合约束的最新版本的模块。

### meta-arguments

除了**source**和**version**，Terraform还定义了一些对所有模块/资源生效的可选元参数:

+ **count**：在单模块中创建模块的多个实例。
+ **for_each**：在单模块中创建模块的多个实例。
+ **providers**：将provider配置传递给子模块，如果没有显式指定，则子模块将继承默认provider。
+ **depends_on**：定义模块之间的依赖关系。

目前module块还不支持lifecycle参数。

## 如何引用子模块中的资源属性

由于模块中的资源被封装起来，外部无法直接访问，因此Terraform提供了子模块输出值声明的方式供用户有选择地将某些值向父模块传递以便其他资
源进行引用。

例如在network模块中定义VPC，子网和安全组资源，在CCE模块中使用这三个资源的ID。则在network模块中将这三个值输出为三个变量供根模块调用
并传递给CCE模块:

```
# network module
output "vpc_id" {
  value = huaweicloud_vpc.example.id
}

output "network_id" {
  value = huaweicloud_vpc_subnet.example.id
}

output "security_group_id" {
  value = huaweicloud_networking_secgroup.example.id
}
```

```
# root module
module "network" {
  source = "./modules/vpc-example"

  ...
}

module "cce" {
  source = "./modules/cce-example"

  vpc_id            = module.network.vpc_id
  network_id        = module.network.network_id
  security_group_id = module.network.security_group_id
}
```

## 如何建立依赖关系

modules结构树中除了通过对输出值进行引用建立依赖关系外还可以通过depends_on元参数建立模块与模块间的依赖关系:

```
module "sfs_turbo" {
  source = "./modules/sfs-turbo-example"

  ...
}

module "ecs" {
  source = "./modules/ecs-example"

  depends_on = [module.sfs_turbo]

  ...
}
```

## 如何有效运用know after apply属性或参数建立依赖解决问题

在脚本开发过程中不免遇到需要中途修改某些文件内容并在后续的资源中引用修改后内容的场景，此时如果是通过file函数对文件进行内容提取，那
么其属性为`know before apply`，无法应用修改后的文本内容，因此需要通过调用一些具有`know after apply`属性的参数将其从
`know before apply`变为`know after apply`，例如在对ECS实例注入`user_data`时需要将shell脚本中的`EXPORT_LOCATION`替换为
SFS turbo的`EXPORT_LOCATION`，因此如果只在**sfs turbo**模块中对脚本进行修改，那么ECS实例注入的**user_data**便是修改前的内容:

```
resource "huaweicloud_compute_instance" "example" {
  ...

  user_data = <<EOT
echo '${file(var.local_file_path)}' > ${var.remote_file_path}
EOT
}

# Throws an error that the value of the user_data field is inconsistent with the 'terraform apply'.
```

通过加入依赖解决此问题:

```
resource "huaweicloud_compute_instance" "example" {
  ...

  user_data = <<EOT
echo '${replace(file(var.local_file_path), "EXPORT_LOCATION", var.export_location)}' > ${var.remote_file_path}
EOT
}
```

通过Know After Apply的export_location告诉Terraform：ECS实例中的user_data需要待Apply之后才能知道值，也就是需要等SFS执行完毕才能
告知ECS实例export_location一个确切的值。

## 如何向我们贡献代码

在向本仓库贡献代码前请仔细阅读下述要求：

### 如何贡献样例

贡献的样例必须是对应modules的典型应用场景，可正确执行，无异常。具体要求如下：

+ 必须包含**README.md**，且内容包含样例介绍、执行效果说明、入参及出参列表（包含描述）及版本约束等。
+ **variables.tf**和**outputs.tf**各参数包含描述，部分参数可加入自定义校验规则。
+ 各资源及参数符合HCL规范和Clean Code标准。

### 如何贡献modules

贡献的modules必须符合本文上述结构和约束，可正确执行，无异常。具体要求如下：

+ 根模块和每个子模块都必须包含**README.md**，且内容包含样例介绍、执行效果说明、入参及出参列表（包含描述）及版本约束等。
+ **variables.tf**和**outputs.tf**各参数包含描述，部分参数可加入自定义校验规则。
+ 各资源及参数符合HCL规范和Clean Code标准。
+ 不过度使用数据源查询，不过度耦合。
