resource "random_string" "suffix" {
  length  = 6
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-azlab-${random_string.suffix.result}"
  location = var.location
}
