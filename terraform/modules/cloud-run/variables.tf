variable "name" {
  description = "Cloud Run service name"
  type        = string
}

variable "image" {
  description = "Container image"
  type        = string
}

variable "region" {
  description = "Deployment region"
  type        = string
}
