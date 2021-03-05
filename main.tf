module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "ssh-key" {
  source = "./modules/ssh-key"
  namespace = var.namespace
}