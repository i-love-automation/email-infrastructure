variable "terraform_organization" {
  type        = string
  description = "The organization name on terraform cloud"
  nullable    = false
}

variable "tfe_token" {
  description = "TFE Team token"
  nullable    = false
  default     = false
  sensitive   = true
}

variable "project" {
  type        = string
  nullable    = false
  description = "The name of the project that hosts the environment"
}

variable "service" {
  type        = string
  nullable    = false
  description = "The name of the service that will be run on the environment"
}

variable "domain_name" {
  type        = string
  nullable    = false
  description = "The project registered domain name that cloudfront can use as aliases, for now only one domain is supported"
  default     = ""
}

variable "ses_domain_verification_success" {
  type        = bool
  nullable    = true
  description = "Domain is verified by SES"
  default     = false
}
#variable "hosting_zone_name" {
#  type        = string
#  nullable    = false
#  description = "The name of the route53 hosting zone"
#  default     = false
#}
#
variable "hosting_zone_id" {
  type        = string
  nullable    = false
  description = "The id of the route53 hosting zone"
  default     = false
}