terraform {
  required_providers {
    atlassian-operations = {
        source = "registry.terraform.io/atlassian/atlassian-operations"
    }
  }
}

provider "atlassian-operations" {
  cloud_id        = var.atlassian_cloud_id
  domain_name     = var.atlassian_domain_name
  email_address   = var.atlassian_email_address
  token           = var.atlassian_token
  org_admin_token = var.atlassian_org_admin_token
  product_type    = var.atlassian_product_type
}

data "atlassian-operations_user" "example" {
  email_address = "user1@example.com"
  organization_id = "XXXXXXXXXXXXXXX"   // only required for Compass
}

output "example" {
  value = "data.atlassian-operations_user.example"
}
