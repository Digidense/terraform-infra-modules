## CREATE KARPENTER :

`` $ helm repo add karpenter https://charts.karpenter.sh ``
`` $ helm repo update ``
`` $ kubectl create namespace karpenter ``
$ helm install karpenter karpenter/karpenter \
  --namespace karpenter \
  --set serviceAccount.create=true \
  --set clusterName=Demo_Cluster \  ## change the cluster name
  --set clusterEndpoint=https://C2FCED4833AA9C301D579224E2168885.sk1.us-east-1.eks.amazonaws.com \  ## change the cluster endpoint
  --set aws.defaultInstanceProfile=default \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set settings.aws.interruptionQueueName=your-interruption-queue-name

-----------------------------------------------------------------------------------------------------------------  
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

