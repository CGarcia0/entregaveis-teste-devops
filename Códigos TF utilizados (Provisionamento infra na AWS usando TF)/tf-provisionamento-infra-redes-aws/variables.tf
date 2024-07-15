variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "VPC name"
  default     = "vpc-avaliacao-infra"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.110.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1c", "us-east-1d"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.110.3.0/24", "10.110.4.0/24", "10.110.5.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.110.6.0/24", "10.110.7.0/24", "10.110.8.0/24"]
}

variable "key_name" {
  description = "Key name for accessing the instances"
  default     = "nat-instance-key"
}

variable "ami_id" {
  description = "AMI ID for the Jenkins instance"
  default     = "ami-0dc2d3e4c0f9ebd18" 
}
