resource "docker_image" "docker" {
  name = aws_ecr_repository.ecr.repository_url
  build {
    path       = "../"
    dockerfile = "Dockerfile"
  }
  depends_on = [aws_ecr_repository.ecr]
}