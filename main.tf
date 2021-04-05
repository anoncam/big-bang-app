// https://github.com/fluxcd/terraform-provider-flux


# Provider
terraform {
  required_version = ">= 0.13"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.10.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.1.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}


# Namespace

resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_secret" "git" {
    metadata {
        name = "git-credentials"
        namespace = var.namespace
    }
    data = {
        username = var.git_user
        password = var.git_token
    }
}


data "flux_sync" "main" {
  target_path = var.path
  url         = var.gitrepository
  branch      = var.branch

  secret = "git-credentials"

  name = var.name
  namespace = var.namespace
}


data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body  = each.value
}

# ImagePullSecrets



