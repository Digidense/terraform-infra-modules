locals {
  ecr_readonly_policy_arn    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  eks_cni_policy_arn         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  eks_worker_node_policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  amazoneksclusterpolicy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  cloudwatch_full_access_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  additional_policies = [
    local.ecr_readonly_policy_arn,
    local.eks_cni_policy_arn,
    local.eks_worker_node_policy_arn,
    local.cloudwatch_full_access_arn,
  ]
}

# Creating EKS role for EKS and EC2 service
resource "aws_iam_role" "eks_role" {
  name = var.role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["eks.amazonaws.com", "ec2.amazonaws.com"]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AmazonEKSClusterPolicy to the EKS role
resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
  name       = var.eks_cluster_attachment_name
  roles      = [aws_iam_role.eks_role.name]
  policy_arn = local.amazoneksclusterpolicy_arn
}

# Creating policy attachment for EKS cluster
resource "aws_iam_policy_attachment" "eks_node_policy_attachments" {
  count      = 4
  name       = "${var.node_attachment_name}-${count.index}"
  roles      = [aws_iam_role.eks_role.name]
  policy_arn = element(local.additional_policies, count.index)
}

# Creating KMS key for EKS encryption
resource "aws_kms_key" "eks_kms" {
  description = "KMS key for EKS cluster encryption"
}

# Creating KMS alias for easier reference
resource "aws_kms_alias" "eks_kms_alias" {
  name          = "alias/eks-cluster-keysddd"
  target_key_id = aws_kms_key.eks_kms.id
}

# Attach the KMS policy to the EKS role
resource "aws_iam_role_policy" "eks_kms_policy" {
  name = "eks-kms-policy"
  role = aws_iam_role.eks_role.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : aws_kms_key.eks_kms.arn
      }
    ]
  })
}

# VPC module referring to create EKS cluster
module "vpc_module" {
  source = "git::https://github.com/Digidense/terraform_module.git//vpc?ref=feature/DD-42-VPC_module"
}

# Creating the EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [
      module.vpc_module.subnet_pri01,
      module.vpc_module.subnet_pri02
    ]
    security_group_ids     = [module.vpc_module.security_group_id]
    endpoint_public_access = var.endpoint_access
  }
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_kms.arn
    }
  }
  timeouts {
    create = "30m"
  }
}

# Creating the CNI addon for the EKS cluster
resource "aws_eks_addon" "cni" {
  cluster_name  = aws_eks_cluster.my_cluster.name
  addon_name    = var.addons_versions[0].name
  addon_version = var.addons_versions[0].version
}

# Creating the kube-proxy addon for the EKS cluster
resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.my_cluster.name
  addon_name    = var.addons_versions[1].name
  addon_version = var.addons_versions[1].version
}

# Creating the CoreDNS addon for the EKS cluster with a corrected version
resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.my_cluster.name
  addon_name    = var.addons_versions[2].name
  addon_version = var.addons_versions[2].version

  timeouts {
    create = "30m"
  }
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_role" {
  name = var.node_role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_role_attachments" {
  count      = length(local.additional_policies)
  role       = aws_iam_role.eks_node_role.name
  policy_arn = element(local.additional_policies, count.index)
}

# Launch Template
resource "aws_launch_template" "eks_node_template" {
  name_prefix = "eks-node-template-"
  #  image_id      = var.ami_id
  instance_type = "t3.2xlarge"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [module.vpc_module.security_group_id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Node Group
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids = [
    module.vpc_module.subnet_pri01,
    module.vpc_module.subnet_pri02
  ]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.mix_size
  }

  launch_template {
    id      = aws_launch_template.eks_node_template.id
    version = "$Latest"
  }

  depends_on = [
    aws_eks_cluster.my_cluster,
  ]
}


data "tls_certificate" "eks_oidc" {
  url = "https://oidc.eks.${var.region}.amazonaws.com/id/${aws_eks_cluster.my_cluster.id}"
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = "https://oidc.eks.${var.region}.amazonaws.com/id/${aws_eks_cluster.my_cluster.id}"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "eks_irsa_role" {
  name = "eks-irsa-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.oidc_provider.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-node"
          }
        }
      }
    ]
  })
}

