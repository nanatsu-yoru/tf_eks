terraform {

  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0.6"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=2.2.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">=2.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}