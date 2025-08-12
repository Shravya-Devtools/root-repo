variable "docker_image" {
  description = "Docker image to deploy to ECS"
  type        = string
}

variable "lambda_zip_url" {
  description = "URL of Lambda zip package"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for ECS service"
  type        = list(string)
}
