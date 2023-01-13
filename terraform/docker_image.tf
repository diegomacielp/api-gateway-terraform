resource "docker_image" "docker" {
  name = aws_ecr_repository.ecr.repository_url
  build {
    path       = "../"
    dockerfile = "Dockerfile"
  }
  depends_on = [aws_ecr_repository.ecr]
  provisioner "local-exec" {
    command = "aws --profile homologacao ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
  provisioner "local-exec" {
    command = "docker push ${docker_image.docker.name}"
  }
}