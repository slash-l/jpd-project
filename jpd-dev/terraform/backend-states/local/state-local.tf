terraform {
  backend "local" {
    path = "slash.tfstate"
  }
}

resource "local_file" "terraform-introduction" {
  content  = "this is a terraform state demo"
  filename = "${path.root}/terraform-guides-by-slash.txt"
}



