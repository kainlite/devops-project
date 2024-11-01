resource "aws_iam_role" "this" {
  name = "${var.cluster_name}-eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this.name
}

resource "aws_eks_cluster" "this" {
  name     = "${var.cluster_name}-eks"
  role_arn = aws_iam_role.this.arn

  version = var.cluster_version

  vpc_config {
    endpoint_public_access = var.endpoint_public_access
    vpc_id                 = var.vpc_id
    subnet_ids             = flatten(concat(var.subnet_ids))
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.this]
}
