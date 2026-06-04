locals {
  root_user     = var.root_user
  root_password = var.root_password != null ? var.root_password : random_password.mongodb_root_password.result
}
