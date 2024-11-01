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
  default     = "default.redis6.2"
}

variable "engine_version" {
  description = "The version of the engine to use for the cluster"
  type        = string
  default     = "6.2"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
