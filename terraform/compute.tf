
locals {
  zones = [1, 2, 3]
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "main" {

  count = length(local.zones)

  name                        = "vmss-azlab-${random_string.suffix.result}-zone${count.index}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  platform_fault_domain_count = 1
  zones                       = [local.zones[count.index]]

}

resource "azurerm_network_interface" "zones" {

  count = length(local.zones)

  name                = "nic-vmazlab${random_string.suffix.result}zone${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.zones[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {

  count = length(local.zones)

  name                         = "vmazlab${random_string.suffix.result}zone${count.index}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  size                         = var.sku_name
  admin_username               = "adminuser"
  zone                         = local.zones[count.index]
  virtual_machine_scale_set_id = azurerm_orchestrated_virtual_machine_scale_set.main[count.index].id

  network_interface_ids = [
    azurerm_network_interface.zones[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}