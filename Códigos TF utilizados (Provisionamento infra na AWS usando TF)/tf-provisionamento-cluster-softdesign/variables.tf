variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "avaliacao-infra-cluster"
}

variable "cluster_version" {
  description = "EKS cluster version"
  default     = "1.30" 
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnets" { 
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  default     = 3
}

variable "max_capacity" {
  description = "Maximum number of worker nodes"
  default     = 5 
}

variable "min_capacity" {
  description = "Minimum number of worker nodes"
  default     = 2  
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  default     = "t3.small"
}

variable "environment" {
  description = "Environment name"
  default     = "production"
}