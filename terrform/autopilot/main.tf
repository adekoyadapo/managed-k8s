# Summary: Creates a GKE (Google Kubernetes Engine) Autopilot cluster.
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
    }
  }
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# GKE
resource "google_container_cluster" "autopilot" {
  name             = "${var.project_id}-auto"
  location         = var.region
  enable_autopilot = true
}

module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [google_container_cluster.autopilot]
  project_id   = var.project_id
  location     = google_container_cluster.autopilot.location
  cluster_name = google_container_cluster.autopilot.name
}
resource "local_file" "kubeconfig" {
  content         = module.gke_auth.kubeconfig_raw
  filename        = "kubeconfig-${var.project_id}-auto"
  file_permission = "0600"
}