variable "db_size" {
  description = "The size of the database in GB"
  type        = number
  default     = 5
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "default"
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
