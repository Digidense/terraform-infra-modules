resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "karpenter-provisioner"
    }
    spec = {
      requirements = [
        {
          key      = "karpenter.sh/provisioned-by"
          operator = "In"
          values   = ["karpenter"]
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = ["t3.medium", "m5.large"]
        }
      ]
      provider = {
        subnetSelector = {
          "karpenter.sh/discovery" = aws_eks_cluster.my_cluster.name
        }
        securityGroupSelector = {
          "karpenter.sh/discovery" = aws_eks_cluster.my_cluster.name
        }
        tags = {
          "karpenter.sh/discovery" = aws_eks_cluster.my_cluster.name

        }
        ttlSecoundsAfterEmpty : 30
      }
    }
  }
}
