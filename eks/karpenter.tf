# Create the IAM role for Karpenter
resource "aws_iam_role" "karpenter_role" {
  name = "KarpenterControllerRole-${var.eks_cluster_name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "karpenter.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


# Attach the required policies to the Karpenter role
resource "aws_iam_role_policy_attachment" "karpenter_controller_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ])

  role       = aws_iam_role.karpenter_role.name
  policy_arn = each.value
}

# Create IAM policy specific for Karpenter
resource "aws_iam_policy" "karpenter_custom_policy" {
  name = "KarpenterCustomPolicy-${var.eks_cluster_name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateFleet",
          "ec2:DescribeInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeKeyPairs",
          "ec2:CreateTags",
          "ec2:DescribeLaunchTemplates",
          "iam:PassRole"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Attach the custom policy to the Karpenter role
resource "aws_iam_role_policy_attachment" "karpenter_custom_policy_attachment" {
  role       = aws_iam_role.karpenter_role.name
  policy_arn = aws_iam_policy.karpenter_custom_policy.arn
}


# Deploy Karpenter using Helm
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.29.0" # Make sure to check for the latest version
  namespace  = "karpenter"

  values = [
    <<EOF
controller:
  clusterName: ${var.eks_cluster_name}
  clusterEndpoint: ${aws_eks_cluster.my_cluster.endpoint}
  defaultInstanceProfile: ${var.eks_instance_profile_name}
  serviceAccount:
    create: true
    name: karpenter
    annotations:
      eks.amazonaws.com/role-arn: ${aws_iam_role.karpenter_role.arn}
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: karpenter.sh/provisioner-name
                operator: In
                values:
                  - default
EOF
  ]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_role.arn
  }
}

# Create namespace for Karpenter
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

# Create EKS cluster auth data
data "aws_eks_cluster_auth" "my_cluster" {
  name = aws_eks_cluster.my_cluster.name
}