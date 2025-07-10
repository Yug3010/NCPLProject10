provider "azurerm" {
  features {}
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
  scope                = "/subscriptions/6c0158cc-0a36-4f93-b3bf-20d1ae9bb55b"
  policy_definition_id = azurerm_policy_definition.custom_policy.id

  parameters = jsonencode({
    "tagName": {
      "value": "environment"
    }
  })
}
