variable "name" {
  description = "Load balancer name"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs to use for the load balancer"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The VPC ID to use for the target group"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
