variable "role_name" {
  type        = string
  description = "Name of the IAM role for the EKS cluster"
  default     = "eks-policy_eks"
}

variable "node_attachment_name" {
  type        = string
  description = "Name of the IAM policy attachment for the EKS node group"
  default     = "eks-node-attachm_eks"
}

variable "eks_cluster_attachment_name" {
  type        = string
  description = "Name of the IAM policy attachment for the EKS cluster"
  default     = "eks-policy-attach_eks"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "Demo_Cluster"
}

variable "addons_versions" {
  type = list(object({
    name    = string
    version = string
  }))
  description = "List of versions of addons to be installed on the EKS cluster"
  default = [
    {
      name    = "vpc-cni"
      version = "v1.18.1-eksbuild.3"
    },
    {
      name    = "kube-proxy"
      version = "v1.29.3-eksbuild.2"
    },
    {
      name    = "coredns"
      version = "v1.11.1-eksbuild.9"
    }
  ]
}

variable "node_group_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "Node_Group_eks"
}

variable "cluster_version" {
  type        = string
  description = "Eks cluster version"
  default     = "1.29"
}

variable "desired_size" {
  type        = number
  description = "desired_size EKS cluster node creation"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "max_size EKS cluster node creation"
  default     = 2
}

variable "min_size" {
  type        = number
  description = "mix_size EKS cluster node creation"
  default     = 1
}

variable "instance_types" {
  type        = list(string)
  description = "List of instance types for Karpenter"
  default     = ["t3a.medium"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "count_num" {
  description = "Number of subnets"
  type        = number
}

variable "karpenter_instance_types" {
  description = "Instance types for Karpenter"
  type        = list(string)
  default     = ["t3a.medium"]
}

variable "encrypt" {
  description = "Enable encryption"
  type        = bool
  default     = true
}

variable "management_nodes" {
  description = "Management nodes"
  type        = list(string)
  default     = ["t3.medium"]
}
# Variables for KMS
variable "aliases_name" {
  description = "Aliases_name for KMS "
  type        = string
  default     = "alias/kms_key"
}

variable "deletion_window_in_days" {
  description = "deletion_window_in_days for KMS "
  type        = number
  default     = 7
}