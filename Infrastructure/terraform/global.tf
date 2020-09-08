terraform {
  required_providers {
    azurerm = "~> 2.21"
  }
}

provider "azurerm" {
  features  {}
}

resource "azurerm_resource_group" "cqrs_global" {
  name                  = "${var.application_name}_global_rg"
  location              = var.locations[0]
}

resource "azurerm_resource_group" "cqrs_region" {
  count                 = length(var.locations)  
  name                  = "${var.application_name}_${var.locations[count.index]}_rg"
  location              = var.locations[count.index]
}

resource "azurerm_cosmosdb_account" "cqrs_db" {
  name                            = var.cosmosdb_name
  resource_group_name             = azurerm_resource_group.cqrs_global.name
  location                        = azurerm_resource_group.cqrs_global.location
  offer_type                      = "Standard"
  kind                            = "GlobalDocumentDB"
  enable_multiple_write_locations = true
  enable_automatic_failover       = true

  consistency_policy {
    consistency_level             = "Session"
  }

  geo_location {
    location                      = var.locations[0]
    failover_priority             = 0
  }

  dynamic "geo_location" {
    for_each = slice(var.locations, 1, length(var.locations))
    content {
      location                    = geo_location.value
      failover_priority           = 1
    }
  }
}

resource "azurerm_container_registry" "cqrs_acr" {
  name                     = var.acr_account_name
  resource_group_name      = azurerm_resource_group.cqrs_global.name
  location                 = azurerm_resource_group.cqrs_global.location
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = slice(var.locations, 1, length(var.locations))
}

resource "azurerm_log_analytics_workspace" "cqrs_logs" {
  name                     = var.loganalytics_account_name
  resource_group_name      = azurerm_resource_group.cqrs_global.name
  location                 = azurerm_resource_group.cqrs_global.location
  sku                      = "pergb2018"
}

resource "azurerm_application_insights" "cqrs_ai" {
  name                     = var.ai_account_name
  resource_group_name      = azurerm_resource_group.cqrs_global.name
  location                 = azurerm_resource_group.cqrs_global.location
  application_type         = "web"
}
