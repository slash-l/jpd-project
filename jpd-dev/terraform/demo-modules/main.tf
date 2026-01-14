module "local-file" {
  source  = "./random-file"
  prefix  = "mumu"
  content = "Hi guys, this is terraform module\nBest wishes!"
}

output "fileName" {
  value = module.local-file.file_name
}
