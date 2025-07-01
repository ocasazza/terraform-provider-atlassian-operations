variable "atlassian_cloud_id" {
  description = "Atlassian Cloud ID"
  type        = string
  sensitive   = true
}

variable "atlassian_domain_name" {
  description = "Atlassian domain name (e.g., domain.atlassian.net)"
  type        = string
}

variable "atlassian_email_address" {
  description = "Email address for Atlassian account"
  type        = string
  sensitive   = true
}

variable "atlassian_token" {
  description = "API token created in Atlassian account settings"
  type        = string
  sensitive   = true
}

variable "atlassian_org_admin_token" {
  description = "NON-SCOPED API Token created in Organization administration (only required for Compass)"
  type        = string
  sensitive   = true
}

variable "atlassian_product_type" {
  description = "Atlassian operations product type (jira-service-desk or compass)"
  type        = string
  default     = "jira-service-desk"
}
