output "lambda_function_name" {
  value = aws_lambda_function.my_lambda.function_name
}

output "ecs_service_name" {
  value = aws_ecs_service.my_service.name
}
