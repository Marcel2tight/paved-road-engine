variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the node pool"
  type        = string
  default     = "default-node-pool"
}

variable "region" {
  description = "Region for the cluster"
  type        = string
}

variable "network" {
  description = "VPC network"
  type        = string
}

variable "subnetwork" {
  description = "VPC subnetwork"
  type        = string
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
  default     = 1
}

variable "service_account_email" {
  description = "Node service account email"
  type        = string
}

variable "oauth_scopes" {
  description = "OAuth scopes for nodes"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "tags" {
  description = "Network tags"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}
