# Budget for AKS cluster
resource "azurerm_consumption_budget_resource_group" "aks" {
  name              = "${var.cluster_name}-budget"
  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  amount     = 500
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }

  notification {
    enabled   = true
    threshold = 80
    operator  = "GreaterThan"

    contact_emails = var.budget_alert_emails
  }

  notification {
    enabled   = true
    threshold = 100
    operator  = "GreaterThan"

    contact_emails = var.budget_alert_emails
  }
}

# Data source for current subscription
data "azurerm_client_config" "current" {}

# Tags for cost tracking
resource "azurerm_tag" "cost_center" {
  name = "CostCenter"
}

resource "azurerm_tag" "environment" {
  name = "Environment"
}
