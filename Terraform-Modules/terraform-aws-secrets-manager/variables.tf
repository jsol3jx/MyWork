variable "secret_name" {
  description = "Name of Secret"
  type        = map(string)
  default = {
    keyA = "SysSBTestPW1",
    keyB = "testPW1",
    keyC = "HelloPW1"
  }
}

variable "secret_tag" {
  description = "The use case of the secret being created"
  default     = ""
}
variable "username" {
  description = "ID assigned to new password creation of each key"
  default     = "admin"
}