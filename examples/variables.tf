variable "subscription_id" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "tenant_id" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "client_id" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
  default     = ""
}

variable "rg_name" {
  description = "The name of the resource group in which to create the PostgreSQL Server"
  type        = string
}

variable "identity_name" {
  description = "The name of the User Assigned Identity"
  type        = string
}

variable "event_grid_sub_config" {
  description = "Specifies the EventGrid Subscription configuration"
  type = list(object({
    topic_name = string
    subscription = list(object({
      name                              = string
      event_types_filter                = optional(list(string))
      expiration_time_utc               = optional(string)
      is_merchant_webhook               = optional(bool, false)
      webhook_endpoint                  = optional(string)
      max_event_delivery_attempts       = optional(number)
      event_time_to_live_min            = optional(number)
      max_events_per_batch              = optional(number)
      preferred_batch_size_in_kilobytes = optional(number)
      delivery_property = optional(list(object({
        delivery_property_header_name = optional(string)
        delivery_property_type        = optional(string)
        delivery_property_value       = optional(string)
        delivery_property_source      = optional(string)
        delivery_property_secret      = optional(bool)
      })))
    }))
  }))
  default = null
}