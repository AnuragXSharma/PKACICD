terraform {
  required_version = ">= 1.10.0"

  # This is the "Save Game" location
  backend "s3" {
    bucket       = "pkacicd-terraform-state" # Use your bucket name here
    key          = "eks/terraform.tfstate"           # Where the file lives in S3
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true                              # Native S3 locking (No DynamoDB needed!)
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- VPC (Network) ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "pkacicd-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # Saves money for a dev/test cluster
}

# --- EKS (Kubernetes Cluster) ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "pkacicd-cluster"
  cluster_version = "1.30"

  # Tell EKS to use the network we just made
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  # Allow the cluster to be managed by the IAM Role we created for GitHub
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    main_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"]
    }
  }
}
