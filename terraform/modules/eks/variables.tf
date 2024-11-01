variable "cluster_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "The desired Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "A list of subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "instance_types" {
  description = "A list of instance types for the EKS nodes"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 0
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 2
}

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
