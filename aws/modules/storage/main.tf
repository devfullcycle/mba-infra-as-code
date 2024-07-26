resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-resources"
  location = "East US"
}

resource "azurerm_storage_account" "storageacc" {
  name                     = replace("${var.prefix}storageacc", "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.storageacc.name
  container_access_type = "private"
}
