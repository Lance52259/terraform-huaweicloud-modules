# terraform-huaweicloud-modules

本仓库提供多套[**Terraform**](https://www.terraform.io/language)模板供开发者参考或在其脚本中引用，各模块使用说明参考其下
`README.md`文档。欢迎各位初学者前来学习以及欢迎各位开发者向本仓库[贡献modules代码和样例](#如何向我们贡献代码)。

## Module学习材料

本仓库提供了面向初学者的学习资料，可点击下列链接直达对应章节或根据[导航页](examples/learning/README.md)进行选择，

+ [Chapter1 如何构建根模块](examples/learning/chapter1/README.md)
+ [Chapter2 如何构建子模块](examples/learning/chapter2/README.md)

## Module基本介绍

模块是可以同时使用多个资源的容器，由目录中多个保存在一起的`.tf`或`.tf.json`文件中定义的资源组成。
模块是实现Terraform包装和重用资源配置的重要方式。

## 模块分类

模块主要分为两类:

+ **根模块**：每个Terraform配置中都至少有一个模块，我们称之为根模块。  
  该模块由主工作目录中的多个`.tf`或`.tf.json`文件组成，用于声明华为云资源或定义子模块，还包含了鉴权的声明以及provider的版本引用。
+ **子模块**：在子目录中定义的被根模块或父模块调用的模块称为子模块，该模块由子目录中的多个`.tf`或`.tf.json`文件组成，内容与根模块
  大抵相同，区别在于可缺省鉴权部分的声明。子模块的内容可以在同一个根模块或父模块中被多次调用，同样多个根模块或父模块配置也可以共同
  用于一个子模块中。

## 模块结构

一个项目通常由上述两种类型的多个模块构成，以树状的形式呈现。  
如构建一个可用的CCE集群声明CCE集群和节点资源以及关联所需的网络。资源按类型划分为网络和容器两个部分，因此modules目录下应当包含这两
个部分的子模块目录，其模块结构为:

```
huaweicloud-provider-example
|- main.tf
|- variables.tf
|- outputs.tf (Optional)
|- README.md (Optional)
|- modules
   |- network-example
   |  |- main.tf
   |  |- varibales.tf
   |  |- outputs.tf
   |- container-example
      |- main.tf
      |- varibales.tf
      |- outputs.tf (Optional)
```

## 模块声明

根模块和父模块中包含一个或多个的module块声明，其声明语法如下所示:

```hcl
module "container" {
  source = "./modules/container-example"

  vpc_id            = module.network.vpc_id
  network_id        = module.network.network_id
  security_group_id = module.network.security_group_id
}
```

module关键字代表声明对子模块的调用，关键字后面的标签是一个本地使用的名称，通过引用这个名称来引用这个模块的资源属性。在模块声明主体
中（`{`和`}`之间）的是模块的参数，包含：**source**、**version**、**inputs** 和**meta-arguments**，其约束如下:

+ **source**参数在所有模块中都强制要求赋予。
+ 建议对Hashicorp官方发布的模块使用**version**参数控制引用版本。
+ 所有需要向子模块进行传递的依赖于其他模块的资源参数、属性或当前模块的输入变量都应该定义于**inputs**中，如上述示例中的`vpc_id`、
`network_id`和`security_group_id`。
+ **meta-arguments**适用于所有模块。

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

**version**参数接受一个用于约束版本的字符串，配置此参数后Terraform将使用符合约束的最新版本的模块。

### inputs

模块之间通常需要相互引用属性或变量值，**inputs**便是把这些参数或变量值向子模块传递的集中声明。  
等号左侧是子模块中接收该变量值的变量名称，等号右侧是声明于当前模块下的输入变量或来自其他同级模块的输出变量引用。

```
vpc_name = var.vpc_name
vpc_id   = module.network.vpc_id
```

### meta-arguments

除了**source**和**version**，Terraform还定义了一些对所有模块/资源生效的可选元参数:

+ **count**：在单模块中创建模块的多个实例。
+ **for_each**：在单模块中创建模块的多个实例。
+ **providers**：将provider配置传递给子模块，如果没有显式指定，则子模块将继承默认provider。
+ **depends_on**：定义模块之间的依赖关系。

目前module块还不支持lifecycle参数。

## 如何引用子模块中的资源属性

由于模块中的资源被封装起来，外部无法直接访问。但Terraform提供了子模块向父模块传递输出值的方式使得用户可以有选择地将某些值向父模块暴
露以便其他资源进行引用。  
例如在network模块中定义VPC、子网和安全组三个资源，随后在容器模块中使用这三个资源的ID：

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
  source = "./modules/network-example"

  ...
}

module "container" {
  source = "./modules/container-example"

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
