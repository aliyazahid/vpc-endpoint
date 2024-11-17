variables {
  vpc_id = ""
  region = "eu-west-2"
  aws_service = "dynamodb"
#   security_groups = []
  subnets = []
  vpc_endpoint_type = "Interface"
  vpc_endpoint_policy = null
  app = ""
  org = ""
  owner = ""
  service = ""
  default_tags = {}
  environment  = "unit"
  env = "unit"
}
run "setup" {

  module {
    source = "./tests/setup"
  }

}

run "integration_test" {

  command = apply

  variables {
    security_groups = [run.setup.security_group_id]
  }

  assert {
    condition     = aws_vpc_endpoint.endpoint.service_name == "com.amazonaws.eu-west-2.dynamodb"
    error_message = "vpc endpoint service name is not correct"
  }
  assert {
    condition     = aws_vpc_endpoint.endpoint.vpc_endpoint_type == "Interface" || aws_vpc_endpoint.endpoint.vpc_endpoint_type == "Gateway" 
    error_message = "vpc endpoint type  is not correct"
  }
  assert {
    condition     = length(aws_vpc_endpoint.endpoint.subnet_ids) > 1
    error_message = "length for subnets is less than 2"
  }
  assert {
    condition     = length(aws_vpc_endpoint.endpoint.security_group_ids) > 0
    error_message = "length fo attached security groups is less than 0"
  }
} 