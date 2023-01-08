data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "subnet" {
  for_each = data.aws_subnet_ids.subnet_ids.ids
  id       = each.value
}