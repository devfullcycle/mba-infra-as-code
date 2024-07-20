output "container_url" {
  value = "https://${azurerm_storage_account.storageacc.name}.blob.core.windows.net/${azurerm_storage_container.container.name}"
}