terraform {
  required_version = "= v1.8.3"

  # 制定下载哪些插件和版本
  # 可以通过命令 terraform providers 查看插件是从哪里下载的
  # terraform init 会下载插件，插件会下载到 .terraform 目录下
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "= 2.5.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

# direxists 函数，用来判断目录是否存在（不判断文件）
output "exists" {
  value = provider::local::direxists("${path.module}/example-directory")
}
output "does_not_exist" {
  value = provider::local::direxists("${path.module}/example2-directory")
}
####################

# 生成一个文件
resource "local_file" "terraform-introduction" {
  content  = "Hi guys, 这是我们的第一个 terraform demo，创建一个文件"
  filename = "${path.module}/terraform-introduction.txt"
}
####################

# 生成随机字符串并输出
resource "random_string" "my_random_string" {
  length  = 12
  special = true
}
output "random_string_value" {
  value = random_string.my_random_string.result
}
####################

# 生成随机密码并隐藏输出
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
output "random_password_value" {
  value = random_password.password.result
  sensitive = true
}
####################
