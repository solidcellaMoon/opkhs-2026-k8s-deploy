variable "region" {
  description = "AWS region to deploy the lab hosts into"
  type        = string
  default     = "ap-northeast-2"
}

variable "ubuntu_ami_id" {
  description = "Ubuntu 24.04 AMI ID for control and worker nodes"
  type        = string
  default     = "ami-0a71e3eb8b23101ed"
}

variable "rocky_ami_id" {
  description = "Rocky Linux 9 AMI ID for worker nodes"
  type        = string
  default     = "ami-06b18c6a9a323f75f"
}

variable "instance_type" {
  description = "Instance type for every host"
  type        = string
  default     = "t3.small"
}

variable "vpc_id" {
  description = "Target VPC ID for all instances"
  type        = string
  default     = "vpc-xxxxxxxxxxxxxxxxx"
}

variable "subnet_id" {
  description = "Private subnet where the hosts will be created"
  type        = string
  default     = "subnet-xxxxxxxxxxxxxxxxx"
}

variable "security_group_ids" {
  description = "Security groups to associate with the hosts"
  type        = list(string)
  default     = ["sg-xxxxxxxxxxxxxxxxx"]
}

variable "resource_prefix" {
  description = "Prefix applied to IAM resources and EC2 Name tags"
  type        = string
  default     = "k8s-hardway"
}

variable "default_tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default = {
    Project = "kubernetes-the-hard-way"
    Managed = "terraform"
  }
}

variable "key_name" {
  description = "EC2 key pair name to enable SSH access"
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP to instances"
  type        = bool
  default     = true
}
