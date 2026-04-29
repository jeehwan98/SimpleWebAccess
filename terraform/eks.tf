/**
  Launch template — blueprint all EC2 nodes use when they boot up:
  1. IMDS (Instance Metadata Service) — how nodes get their IAM credentials
  2. 2 security groups — eks_node SG (ALB access) + cluster SG (control plane communication)
*/
resource "aws_launch_template" "eks_node" {
  name_prefix = "${local.name_prefix}-eks-node-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  vpc_security_group_ids = [
    aws_security_group.eks_node.id,
    aws_eks_cluster.main.vpc_config[0].cluster_security_group_id,
  ]

  tags = local.common_tags
}

/**
  EKS cluster — Kubernetes control plane managed by AWS (no master nodes to manage)
  - endpoint_public_access_cidrs restricts kubectl access to our home IP only
  - depends_on ensures the IAM policy is attached before cluster creation
*/
resource "aws_eks_cluster" "main" {
  name     = "${local.name_prefix}-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = aws_subnet.eks[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["${var.home_ip}/32"]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = local.common_tags
}

/**
  3 node groups, one per AZ:
  - nodegroup-a: desired=1, always running (primary)
  - nodegroup-b: desired=1, scales down to 0 when not needed
  - nodegroup-c: desired=0, costs nothing until scaled up
*/
resource "aws_eks_node_group" "a" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "nodegroup-a"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = [aws_subnet.eks[0].id]
  instance_types  = [var.eks_node_instance_type]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  launch_template {
    id      = aws_launch_template.eks_node.id
    version = aws_launch_template.eks_node.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only,
  ]

  tags = local.common_tags
}

resource "aws_eks_node_group" "b" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "nodegroup-b"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = [aws_subnet.eks[1].id]
  instance_types  = [var.eks_node_instance_type]

  scaling_config {
    desired_size = 1
    min_size     = 0
    max_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_node.id
    version = aws_launch_template.eks_node.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only,
  ]

  tags = local.common_tags
}

resource "aws_eks_node_group" "c" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "nodegroup-c"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = [aws_subnet.eks[2].id]
  instance_types  = [var.eks_node_instance_type]

  scaling_config {
    desired_size = 0
    min_size     = 0
    max_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_node.id
    version = aws_launch_template.eks_node.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only,
  ]

  tags = local.common_tags
}
