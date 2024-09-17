resource "aws_iam_role" "karpenter_controller" {
  name = "KarpenterControllerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "karpenter_controller_policy" {
  name        = "KarpenterControllerPolicy"
  path        = "/"
  description = "Policy for Karpenter to provision and manage EC2 instances."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "eks:DescribeCluster"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
  role       = aws_iam_role.karpenter_controller.name
}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter-a"
  }
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = kubernetes_namespace.karpenter.metadata[0].name
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.16.3"


  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.my_cluster.endpoint
  }

  set {
    name  = "awsRegion"
    value = "us-east-1"
  }

}


