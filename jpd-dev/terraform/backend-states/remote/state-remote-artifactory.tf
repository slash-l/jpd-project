terraform {
    backend "remote" {
        hostname = "demo.jfrogchina.com"
        organization = "slash-terraformBE-dev-local"
        workspaces {
            prefix = "slash-ns-"
        }
    }
}

resource "local_file" "terraform-introduction" {
  content  = "this is a terraform state demo connect to jfrogchina demo"
  filename = "${path.root}/terraform-state-by-slash.txt"
}

