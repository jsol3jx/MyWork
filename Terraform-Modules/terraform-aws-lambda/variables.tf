
variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-2"
}

variable "function_name" {
  description = "Name for the Lambda function"
}

variable "runtime" {
  description = "Run time needed for the lambda function such as python, node.js, go, etc"
}

variable "authorization_type" {
  description = "The type of Lambda Function URL Authoration, ie AWS_IAM or NONE"
  default     = "AWS_IAM"
}

variable "handler_name" {
  description = "Name of your handler file, ie handler.py"
}

/*
variable "usehandler" {
  description = "Variable used when a real handler is needed."
  default     = false
}

variable "lambda_role_name" {
  description = "Name for the role created with the Lambda"
}
*/
