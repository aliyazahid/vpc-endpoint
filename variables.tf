variable "is_aws_service" {
  default = true
  type = bool
  description = "false if crearing endpoint for third party"
}
variable "third_party_service" {
  default = ""
  type = string
  description = "complete value for third party endpoint string" 
}
variable "region" {
#   default = ""
  type = string
  description = "aws region where endpoint will be created"  
}
variable "aws_service" {
#   default = ""
  type = string
  description = "aws service for the endpoint" 
}
variable "vpc_id" {
  type = string
  description = "vpc id for the endpoint"   
}
variable "security_groups" {
  type = list
  description = "list of security group IDs for vpc endpoint."    
}
variable "subnets" {
  type = list
  description = "list of subnet IDs for vpc endpoint."
}
variable "vpc_endpoint_type" {
  default = "Interface"
  type = string
  description = "vpc endpoint type"
}
variable "vpc_endpoint_policy" {
  default = null
  type = string
  description = "JSON policy for the endpoint"
}
variable "default_tags" {
  default = {}
  type = map
  description = "tags for the endpoint"
}
variable "app" {
  default = ""
  type = string
  description = "app tag for endpoint"   
}
variable "environment" {
    default = ""
    type = string
    description = "environment tag for endpoint"
}
variable "owner" {
    default = ""
    type = string
    description = "owner tag for endpoint"
}
variable "org" {
    default = ""
    type = string
    description = "org tag for endpoint"   
}
variable "env" {
    default = ""
    type = string
    description = "env tag for endpoint"   
}