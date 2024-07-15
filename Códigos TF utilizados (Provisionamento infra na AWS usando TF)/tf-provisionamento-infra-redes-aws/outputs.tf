output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "jenkins_instance_id" {
  description = "ID of the Jenkins instance"
  value       = aws_instance.jenkins_instance.id
}

output "jenkins_instance_public_ip" {
  description = "Public IP address of the Jenkins instance"
  value       = aws_instance.jenkins_instance.public_ip
}
