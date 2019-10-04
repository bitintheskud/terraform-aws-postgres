variable aws_region {
  type = string
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC id to create the db in"
}

variable "publicly_accessible" {
  default = false
  description = "Bool to control if instance is publicly accessible"
}

variable "project" {
  type = string
  description = "Project code or identifier"
}

variable "env" {
  type = string
  description = "Environment of the project (production, developement, staging)"
}

variable "db" {
  type = any
  default = {}
  description = "List of variable to apply to postgres"
}

variable "identifier" {
  type = string
  description = "A code or identifier to identify this resource"
}

variable "custom_tags" {
  type = map(string)
  default = {}
  description = "Custom tags to add to all the resource"
}