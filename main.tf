
locals {
  topic_subscription = flatten([
    for v in var.event_grid_sub_config : [
      for record in v.subscription : {
        topic_name                        = v.topic_name
        subscription_name                 = record.name
        labels                            = record.labels
        event_types_filter                = record.event_types_filter
        expiration_time_utc               = record.expiration_time_utc
        is_merchant_webhook               = record.is_merchant_webhook
        webhook_endpoint                  = record.webhook_endpoint
        max_event_delivery_attempts       = record.max_event_delivery_attempts
        event_time_to_live_min            = record.event_time_to_live_min
        max_events_per_batch              = record.max_events_per_batch
        preferred_batch_size_in_kilobytes = record.preferred_batch_size_in_kilobytes
        delivery_property                 = record.delivery_property
      }
    ]
  ])
}

data "azurerm_user_assigned_identity" "app_identity" {
  name                = var.identity_name
  resource_group_name = var.rg_name
}

data "azurerm_eventgrid_topic" "eventgrid_topic" {
  for_each            = { for v in var.event_grid_sub_config : v.topic_name => v }
  name                = each.key
  resource_group_name = var.rg_name
}

data "azurerm_storage_account" "storage_account" {
  for_each = { for v in var.event_grid_sub_config : v.topic_name => v }
  /*name                = var.env == "Prod" ? substr(replace(replace(replace(each.key, "-", ""), "topic", ""), "ccg", "tpc"), 0, 24) : substr(replace(replace(replace(each.key, "-", ""), "topic", ""), "fcc", "tpc"), 0, 24)*/
  name                = substr(replace(replace(each.key, "-", ""), "topic", ""), 0, 24)
  resource_group_name = var.rg_name
}

resource "azurerm_storage_container" "blob_container" {
  for_each              = { for v in local.topic_subscription : "${v.subscription_name}~${v.topic_name}" => v }
  name                  = split("~", each.key)[0]
  storage_account_name  = data.azurerm_storage_account.storage_account[each.value.topic_name].name
  container_access_type = "private"
}

resource "azurerm_eventgrid_event_subscription" "event_subscription" {
  for_each              = { for v in local.topic_subscription : "${v.subscription_name}~${v.topic_name}" => v }
  name                  = split("~", each.key)[0]
  scope                 = data.azurerm_eventgrid_topic.eventgrid_topic[each.value.topic_name].id
  event_delivery_schema = var.schema
  included_event_types  = each.value.event_types_filter
  expiration_time_utc   = each.value.expiration_time_utc
  labels                = each.value.labels

  webhook_endpoint {
    /*url                               = each.value.is_merchant_webhook ? "${var.webhook_function_url}?code=${var.webhook_function_url_code}" : "${var.function_url}?code=${var.function_url_code}&url=${each.value["webhook_endpoint"]}"*/
    url                               = each.value.webhook_endpoint
    max_events_per_batch              = each.value.max_events_per_batch
    preferred_batch_size_in_kilobytes = each.value.preferred_batch_size_in_kilobytes
  }

  dead_letter_identity {
    type                   = "UserAssigned"
    user_assigned_identity = data.azurerm_user_assigned_identity.app_identity.id
  }

  storage_blob_dead_letter_destination {
    storage_account_id          = data.azurerm_storage_account.storage_account[each.value.topic_name].id
    storage_blob_container_name = azurerm_storage_container.blob_container[each.key].name
  }

  retry_policy {
    max_delivery_attempts = each.value.max_event_delivery_attempts
    event_time_to_live    = each.value.event_time_to_live_min
  }

  dynamic "delivery_property" {
    for_each = each.value.delivery_property != null ? [for s in each.value.delivery_property : {
      header_name  = s.delivery_property_header_name
      type         = s.delivery_property_type
      value        = s.delivery_property_value
      source_field = s.delivery_property_source
      secret       = s.delivery_property_secret
    }] : []

    content {
      header_name  = delivery_property.value.header_name
      type         = delivery_property.value.type
      value        = delivery_property.value.value
      source_field = delivery_property.value.source_field
      secret       = delivery_property.value.secret
    }
  }

  lifecycle {
    ignore_changes = [webhook_endpoint[0].preferred_batch_size_in_kilobytes, webhook_endpoint[0].max_events_per_batch]
  }
}
