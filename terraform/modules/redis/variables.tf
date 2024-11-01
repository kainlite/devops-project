variable "cluster_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "node_type" {
  description = "The instance type of the Elasticache node"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "The number of cache nodes in the cluster"
  type        = number
  default     = 1
}

variable "parameter_group_name" {
  description = "The name of the parameter group to associate with this cluster"
  type        = string
  default     = "default.redis7"
}

variable "engine_version" {
  description = "The version of the engine to use for the cluster"
  type        = string
  default     = "7.1"
}

variable "subnet_ids" {
  description = "The subnet IDs to use for the database"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "The security group IDs to use for the database"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
