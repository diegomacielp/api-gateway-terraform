variable "aws_id" {
  type    = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "project_name" {
  type    = string
  default = "api-gateway"
}
variable "project_port" {
  type    = string
  default = "3000"
}