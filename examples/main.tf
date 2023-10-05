provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

module "eventgrid_subscription" {
  source                = "../"
  rg_name               = var.rg_name
  event_grid_sub_config = var.event_grid_sub_config
  identity_name         = var.identity_name
}

