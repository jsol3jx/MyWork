output "task_role_name" {
  description = "ECS Task role name"
  value       = aws_iam_role.ecs_task_execution_role.name
}

output "aws_lb_dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.load_balancer.dns_name
}
