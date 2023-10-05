# Azure Event Grid Topic Event Subscription
This Terraform module to manage Microsoft [Azure EventGrid subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_event_subscription) resource.

### Versioning Rule For This Modules

| Module version | Terraform version |
| -------------- | ----------------- |
| < 1.x.x        | 3.75.x            |


### Usage

There're some examples in the examples folder. You can execute terraform apply command in examples's sub folder to try the module.

```hcl-terraform

provider "azurerm" {
  features {}

}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.72"
    }
  }
  required_version = ">= 0.12"
}

module "eventgrid_subscription" {
  source                      = "../../modules/eventgrid-subscription"
  rg_name                     = "eventgrid-rg"
  event_grid_sub_config       = [
  {
      topic_name = "test-topic"
      subscription = [
        {
          name                        = "test-consumer-user-access-event"
          event_types_filter          = ["USER_CREATED"]
          webhook_endpoint            = "https://test.com/api/eventgrid/v1.0/user-access-event"
          max_event_delivery_attempts = 10
          event_time_to_live_min      = 1440
          delivery_property = [
            {
              delivery_property_header_name = "X-B3-TraceId"
              delivery_property_type        = "Dynamic"
              delivery_property_source      = "data.payload.traceId"
              delivery_property_secret      = false
            }
          ]
        }
      ]
    }
  ]
  
}

```

### Inputs

| Name | Description | Type | Required | Default |
| ---- | ----------- | ---- | -------- | ------- |
| rg_name | The name of the resource group in which storage acc, eventgrid available | string | yes | NA |
| schema | Specifies the schema in which incoming events will be published to this domain | string | no | EventGridSchema |
| event_grid_sub_config | Specifies the EventGrid Subscription configuration | list(object) | no | null |

`event_grid_sub_config` block helps you setup the event grid subscription and accept following Keys

| Name | Description | Type | Required | Default |
| ---- | ----------- | ---- | -------- | ------- |
| topic_name | Specifies the name of the EventGrid Topic | string | yes | NA |
| subscription | Specifies the eventgrid subscription detail | lis(object) | yes | NA |

`subscription` block helps you setup the event grid subscription and accept following Keys

| Name | Description | Type | Required | Default |
| ---- | ----------- | ---- | -------- | ------- |
| name | Specifies the eventgrid subscription name | string | yes | NA |
| event_types_filter | A list of applicable event types that need to be part of the event subscription | list(string) | no | null
| expiration_time_utc | Specifies the expiration time of the event subscription (Datetime Format RFC 3339) | string | no | null |
| webhook_endpoint | Specifies the url of the webhook where the Event Subscription will receive events | string | no | null |
| max_event_delivery_attempts | pecifies the maximum number of delivery retry attempts for events. | number | no | null |
| event_time_to_live_min | Specifies the time to live (in minutes) for events | number | no | null |
| max_events_per_batch | Maximum number of events per batch | number | no | null |
| preferred_batch_size_in_kilobytes | Preferred batch size in Kilobytes | number | no | null |
| delivery_property | One or more delivery_property blocks as defined below | list(object) | no | null |

`delivery_property` block helps you setup the event grid subscription delivery property and accept following Keys

| Name | Description | Type | Required | Default |
| ---- | ----------- | ---- | -------- | ------- |
| delivery_property_header_name | The name of the header to send on to the destination | string | no | null|
| delivery_property_type | Either Static or Dynamic | string | no | null |
| delivery_property_value | If the type is Static, then provide the value to use | string | no | null |
| delivery_property_source | If the type is Dynamic, then provide the payload field to be used as the value. Valid source fields differ by subscription type | string | no | null |
| delivery_property_secret | True if the value is a secret and should be protected, otherwise false | bool | no | false |

