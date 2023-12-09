
resource "azurerm_virtual_network" "main" {
  name                = "vnet-azref-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.address_space

}


resource "azurerm_subnet" "zones" {

  count = length(local.zones)

  name                 = "snet-zone${count.index}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.32.${local.zones[count.index]}.0/24"]

}
