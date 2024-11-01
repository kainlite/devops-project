variable "db_size" {
  description = "The size of the database in GB"
  type        = number
  default     = 5
}

variable "instance_name" {
  description = "The name of the database instance"
  type        = string
  default     = "dev"
}

variable "db_instance_class" {
  description = "The instance class to use"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "postgres"
}

variable "subnet_ids" {
  description = "The subnet IDs to use for the database"
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "The version of the engine to use for the database"
  type        = string
  default     = "16.3"
}

variable "parameter_group_name" {
  description = "The name of the parameter group to use"
  type        = string
  default     = "default.postgres16"
}

variable "vpc_security_group_ids" {
  description = "The security group IDs to use for the database"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
