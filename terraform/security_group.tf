resource "aws_security_group" "security_group_ecs" {
  name        = "security_group_${var.project_name}"
  description = "Permite acesso a Aplicacao"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "External access"
    from_port   = var.project_port
    to_port     = var.project_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}