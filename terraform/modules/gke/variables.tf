variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the GKE node pool"
  type        = string
  default     = "default-node-pool"
}

variable "region" {
  description = "Region for the GKE cluster"
  type        = string
}

variable "network" {
  description = "VPC network name or self link"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name or self link"
  type        = string
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "service_account_email" {
  description = "Service account email for GKE nodes"
  type        = string
}

variable "oauth_scopes" {
  description = "OAuth scopes for GKE nodes"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "tags" {
  description = "Network tags for GKE nodes"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to the cluster and nodes"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the GKE cluster"
  type        = bool
  default     = false
}
