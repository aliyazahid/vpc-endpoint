resource "aws_vpc_endpoint" "endpoint" {
  service_name = var.is_aws_service ? "com.amazonaws.${var.region}.${var.aws_service}" : var.third_party_service
  vpc_id = var.vpc_id
  security_group_ids =  var.security_groups
  subnet_ids = var.subnets
  private_dns_enabled = var.vpc_endpoint_type == "Interface" ? false : true
  vpc_endpoint_type = var.vpc_endpoint_type
  policy = var.vpc_endpoint_policy
  tags = (merge({
    Application = var.app
    Environment = var.environment
    Name = var.is_aws_service ? "${var.org}-${var.env}-${var.app}-${var.aws_service}-endpoint" : "${var.org}-${var.env}-${var.app}-${var.third_party_service}-endpoint"
    Owner = var.owner
    Region = var.region
    Resource_Type = "VPC Endpoint"
    Schedule = "24x7"
    Service = var.is_aws_service ? var.aws_service : var.third_party_service
  },var.default_tags))
}
# variable "is_aws_service" {
#   default = true
#   type = bool
#   description = "false if crearing endpoint for third party"
# }
# variable "third_party_service" {
#   default = ""
#   type = string
#   description = "complete value for third party endpoint string" 
# }