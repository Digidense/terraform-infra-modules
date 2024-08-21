
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

provider "aws" {
  region = var.region
}



provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.my_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.my_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.my_cluster.token
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.my_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.my_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.my_cluster.token
}

