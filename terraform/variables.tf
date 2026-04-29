/**
  Defines everything that can vary between env or that shouldn't be hardcoded
  - sensitive = true > means Terraform won't print their values in terminal output
  - backend_image & frontend_image = start as empty and they'll be filled in after we build and push our Docker images
*/

/** General variables */
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "simplewebaccess"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "prod"
}

/** EKS variables*/
variable "home_ip" {
  description = "Your home IP for EKS private endpoint access (e.g. 1.2.3.4)"
  type        = string
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.small"
}
