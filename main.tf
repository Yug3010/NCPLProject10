terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}




variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_policy_definition" "custom_policy" {
  name         = "enforce-tag-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Enforce tag on resources"
  description  = "This policy ensures all resources have a 'environment' tag."

  policy_rule = jsonencode({
    "if": {
      "not": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": true
      }
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


resource "null_resource" "policy_assignment" {
  depends_on = [azurerm_policy_definition.custom_policy]

    provisioner "local-exec" {
    command = <<EOT
      az policy assignment create \
        --name assign-enforce-tag-policy \
        --scope /subscriptions/${var.subscription_id} \
        --policy ${azurerm_policy_definition.custom_policy.id} \
        --params '{ "tagName": { "value": "environment" } }'
    EOT
  }

}
