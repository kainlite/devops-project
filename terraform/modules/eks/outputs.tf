output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = try(aws_eks_cluster.this.id, null)
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = try(aws_eks_cluster.this.arn, null)
}
