resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "${var.project_name}-log-group"
}