terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"  # or higher like "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

resource "azurerm_policy_definition" "custom_policy" {
  name         = "enforce-tag-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce tag on resources"
  description  = "This policy ensures all resources have a 'environment' tag."

  policy_rule = jsonencode({
    "if": {
      "field": "[concat('tags[', parameters('tagName'), ']')]",
      "equals": null
    },
    "then": {
      "effect": "deny"
    }
  })

  parameters = jsonencode({
    "tagName": {
      "type": "String",
      "metadata": {
        "displayName": "Tag Name",
        "description": "Name of the tag, such as 'environment'"
      }
    }
  })
}

resource "azurerm_policy_assignment" "tag_policy_assignment" {
  name                 = "assign-enforce-tag-policy"
  scope                = "/subscriptions/${var.subscription_id}"
  policy_definition_id = azurerm_policy_definition.custom_policy.id

  parameters = jsonencode({
    "tagName": {
      "value": "environment"
    }
  })
}
