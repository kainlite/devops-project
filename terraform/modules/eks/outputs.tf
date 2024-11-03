output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = try(aws_eks_cluster.this.id, null)
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = try(aws_eks_cluster.this.arn, null)
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = try(aws_eks_cluster.this.endpoint, null)
}

output "eks_node_group_resources" {
  description = "The resources of the node group"
  value       = try(aws_eks_node_group.this.resources, null)
}
