
variable "project" {
  description = "AWS region to deply EKS cluster"
  type        = string
  default     = "jerney"
}

variable "environment" {
  description = "Deployment environment (dev, stagging, prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "jerney-eks"
}


variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "cluster_public_access_cidrs" {
  description = "Trusted CIDR blocks allowed to access the EKS API"
  type        = list(string)
}
