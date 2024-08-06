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

resource "aws_iam_role" "eks_role" {
  name = var.role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
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

resource "aws_iam_policy_attachment" "eks_node_policy_attachments" {
  count      = 4
  name       = "${var.node_attachment_name}-${count.index}"
  roles      = [aws_iam_role.eks_role.name]
  policy_arn = element(local.additional_policies, count.index)
}

resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
  name       = var.eks_cluster_attachment_name
  roles      = [aws_iam_role.eks_role.name]
  policy_arn = local.amazoneksclusterpolicy_arn
}

module "vpc_module" {
  source    = "git::https://github.com/Digidense/terraform-infra-modules.git//vpc?ref=feature/vpc_module"
  vpc_cidr  = var.vpc_cidr
  region    = var.region
  count_num = var.count_num
}

resource "aws_kms_key" "EKS_kms_key" {
  description             = "KMS key for EKS encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name        = "EKS_Key"
    Environment = "Development"
  }
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.EKS_kms_key.arn]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_kms_key_policy" "eks_kms_policy" {
  key_id = aws_kms_key.EKS_kms_key.key_id
  policy = data.aws_iam_policy_document.kms_policy.json
}

resource "aws_kms_alias" "my_alias" {
  name          = var.aliases_name
  target_key_id = aws_kms_key.EKS_kms_key.arn
}

resource "aws_eks_cluster" "my_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids             = module.vpc_module.private_subnet
    security_group_ids     = [module.vpc_module.security_group.id]
    endpoint_public_access = true
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.EKS_kms_key.arn
    }
    resources = ["secrets"]
  }

  timeouts {
    create = "30m"
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.my_cluster.name
  addon_name    = var.addons_versions[0].name
  addon_version = var.addons_versions[0].version

  timeouts {
    create = "30m"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.my_cluster.name
  addon_name    = var.addons_versions[1].name
  addon_version = var.addons_versions[1].version

  timeouts {
    create = "30m"
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.my_cluster.name
  addon_name    = var.addons_versions[2].name
  addon_version = var.addons_versions[2].version

  timeouts {
    create = "30m"
  }
}

resource "aws_launch_template" "eks_worker_launch_template" {
  name          = "${var.node_group_name}_lt"
  image_id      = "ami-0c55b159cbfafe1f0" # Specify your desired AMI ID
  instance_type = "t3.2xlarge"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp2"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_worker_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-worker"
    }
  }
}

resource "aws_iam_instance_profile" "eks_worker_instance_profile" {
  name = "eks-worker-instance-profile"
  role = aws_iam_role.eks_role.name
}

resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_role.arn
  subnet_ids      = module.vpc_module.private_subnet

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  launch_template {
    id      = aws_launch_template.eks_worker_launch_template.id
    version = "$Latest"
  }

  depends_on = [
    aws_eks_cluster.my_cluster,
  ]
}

resource "aws_iam_role_policy_attachment" "eks_additional_policies" {
  count      = length(local.additional_policies)
  role       = aws_iam_role.eks_role.name
  policy_arn = local.additional_policies[count.index]
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
