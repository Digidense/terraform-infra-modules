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

variable "endpoint_access" {
  type        = bool
  description = "endpoint public access"
  default     = true
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
  default     = 3
}

variable "region" {
  type        = string
  description = "region of the EKS cluster node creation"
  default     = "us-east-1"
}

variable "max_size" {
  type        = number
  description = "max_size EKS cluster node creation"
  default     = 4
}

variable "mix_size" {
  type        = number
  description = "mix_size EKS cluster node creation"
  default     = 1
}

#variable "ami_id" {
#  type        = string
#  description = "AMI ID to be used for EKS nodes"
#  default     = "ami-0c8e23f950c7725b9"
#}

variable "eks_instance_profile_name" {
  type        = string
  description = "Instance profile name for Karpenter to use"
  default     = "default"
}

variable "node_role_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "eks_nodegroup_policy"
}