
resource "aws_iam_role_policy_attachment" "karpenter_managed_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ])

  role       = aws_iam_role.eks_role.name
  policy_arn = each.value
}

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

resource "aws_iam_role_policy_attachment" "karpenter_custom_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.karpenter_custom_policy.arn
}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "https://charts.karpenter.sh"
  chart            = "karpenter"
  version          = "v0.16.3"
  namespace        = kubernetes_namespace.karpenter.metadata[0].name
  create_namespace = true
  timeout          = 1200 # Increase timeout to 20 minutes
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
      eks.amazonaws.com/role-arn: ${aws_iam_role.eks_role.arn}
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
}


data "aws_eks_cluster_auth" "my_cluster" {
  name = aws_eks_cluster.my_cluster.name
}
