variable "region" {
  default = "us-west-1"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service."
  type        = bool
  default     = false
}

variable "launch_type" {
  description = "The launch type on which to run your service. Valid values are `EC2` and `FARGATE`"
  default     = "EC2"
}

variable "network_mode" {
  description = "The network mode to use for the task. This is required to be `awsvpc` for `FARGATE` `launch_type` or `null` for `EC2` `launch_type`"
  default     = "awsvpc"
}

variable "platform_version" {
  description = "The platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. More information about Fargate platform versions can be found in the AWS ECS User Guide."
  default     = "LATEST"
}

variable "redeploy_on_apply" {
  description = "Updates the service to the latest task definition on each apply"
  default     = "true"
}

variable "ecs_task_cpu" {
  type        = number
  description = "Should be smaller than task_level_cpu. The number of CPU units used by the task. If using `FARGATE` launch type `task_cpu` must match [supported memory values](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)"
  default     = 512
}

variable "task_definition" {
  description = "A `list(string)` of zero or one ARNs of task definitions, to reuse reuse an existing task definition family and revision for the ecs service instead of creating one DEPRECATED: you can also pass a `string` with the ARN, but that string must be known a plan time."
  default     = []
}

variable "task_definition_arn" {
  type        = string
  default     = ""
  description = "ARN of task definition to use (if provided, will use this instead of creating one via Terraform)"
}

variable "use_latest_task_definition" {
  type        = bool
  default     = false
  description = "If true, automatically use the latest task definition revision (useful when external tools like Harness deploy new revisions)"
}

variable "ignore_task_definition_changes" {
  type        = bool
  default     = false
  description = "If true, Terraform will ignore changes to the task definition after initial creation (useful when external tools manage deployments)"
}

variable "ecs_task_memory" {
  type        = number
  description = "Should be smaller than task_level_memory. The amount of memory (in MiB) used by the task. If using Fargate launch type `task_memory` must match [supported cpu value](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)"
  default     = 512
}

variable "task_level_cpu" {
  type        = string
  default     = "512"
  description = "Task-level CPU units (required for awsvpc network mode)"
}

variable "task_level_memory" {
  type        = string
  default     = "512"
  description = "Task-level memory in MiB (required for awsvpc network mode)"
}

variable "dns_record_name" {
  description = "A record for DNS when used."
  default     = null
}

variable "logs_group" {
  default = "/ecs/"
}

######

variable "ecs_name" {
  description = "Task Definition name, squire-env-etc"
}

variable "env" {
  description = "Environment name such as sandbox, qa, staging, demo, prod."
}

variable "log_retention_period" {
  type        = number
  default     = 30
  description = "Cloudwatch logs retention period"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type the Metabase application will be running on"
}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired capacity for the EC2 auto-scaling group"
}

variable "max_size" {
  type        = number
  default     = 4
  description = "Desired max capacity for the EC2 auto-scaling group"
}

variable "ssl_certificate" {
  type        = string
  default     = ""
  description = "SSL certificate ARN for the Metabase load balancer"
}

variable "lb_drop_invalid_header_fields" {
  type        = bool
  default     = false
  description = "Drop invalid HTTP request headers in load balancer"
}

variable "ecs_task_image" {
  type        = string
  default     = "amazonlinux:2"
  description = "Desired image for the task container"
}

variable "ecs_containerPort" {
  type    = number
  default = 3000
}

variable "ecs_hostPort" {
  type        = number
  default     = 3000
  description = "Host port for bridge network mode (not used in awsvpc mode)"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Desired minimum capacity for the EC2 auto-scaling group"
}

variable "alb_target_type" {
  default     = "ip"
  description = "Desired target type: ip, instance, lambda"
}

variable "lb_container_port" {
  default     = 3000
  description = "Desired LB container port"
}

variable "tg_port" {
  type    = number
  default = 3000
}

variable "tg_protocol" {
  description = "Target group protocol HTTP or HTTPS"
  default     = "HTTP"
}
variable "hc_healthy_threshold" {
  type        = number
  default     = 2
  description = "Healthy threshold for the target group"
}

variable "hc_interval" {
  type        = number
  default     = 30
  description = "Interval for the target group"
}

variable "hc_matcher" {
  type        = string
  default     = "200"
  description = "Matcher for the target group"
}

variable "hc_path" {
  type    = string
  default = "/"
}

variable "hc_port" {
  type        = string
  default     = "traffic-port"
  description = "Port for the target group"
}

variable "hc_timeout" {
  type        = number
  default     = 10
  description = "Timeout for the target group"
}

variable "hc_unhealthy_threshold" {
  type        = number
  default     = 3
  description = "Unhealthy threshold for the target group"
}

variable "hc_protocol" {
  type        = string
  default     = "HTTP"
  description = "Protocol for the target group health check"
}

variable "volume_type" {
  type        = string
  default     = "gp3"
  description = "The type of EBS volume for the launch template (e.g., gp3, gp2, io1)"
}

variable "volume_size" {
  type        = number
  default     = 50
  description = "The size of the EBS volume in GB"
}

variable "volume_iops" {
  type        = number
  default     = 3000
  description = "The number of I/O operations per second (IOPS) for gp3 volumes"
}

variable "volume_throughput" {
  type        = number
  default     = 400
  description = "The throughput in MiB/s for gp3 volumes"
}

variable "delete_on_termination" {
  type        = bool
  default     = true
  description = "Whether to delete the EBS volume when the instance is terminated"
}

variable "instance_refresh_strategy" {
  type        = string
  default     = "Rolling"
  description = "The strategy to use for instance refresh (Rolling, RollingWithPercentage, RollingWithPercentageAndMinHealthyInstances)"
}

variable "encrypted_volume" {
  type        = bool
  default     = false
  description = "Whether to encrypt the EBS volume"
}

variable "health_check_type" {
  type        = string
  default     = "ELB"
  description = "The health check type for the auto-scaling group"
}

variable "health_check_grace_period" {
  type        = number
  default     = 120
  description = "The health check grace period in seconds for the ECS service"
}

variable "enable_ssl" {
  description = "Enable SSL/HTTPS for the load balancer"
  type        = bool
  default     = true
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the ECS service"
}

variable "create_log_group" {
  description = "Whether to create the CloudWatch log group"
  type        = bool
  default     = true
}