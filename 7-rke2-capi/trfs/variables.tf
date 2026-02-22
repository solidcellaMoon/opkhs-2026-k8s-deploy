variable "region" {
  description = "AWS region to deploy the lab hosts into"
  type        = string
  default     = "ap-northeast-2"
}

variable "rocky_ami_id" {
  description = "Rocky Linux 10 AMI ID for all nodes"
  type        = string
  default     = "ami-06b18c6a9a323f75f"
}

variable "vpc_id" {
  description = "Target VPC ID for all instances"
  type        = string
  default     = "vpc-xxxxxxxxxxxxxxxxx"
}

variable "subnet_id" {
  description = "Subnet where all instances will be created"
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

variable "associate_public_ip_by_instance" {
  description = "Public IP association per instance key (k8s_ctr1, k8s_node1, k8s_node2)"
  type        = map(bool)
  default = {
    k8s_ctr1  = true
    k8s_node1 = true
    k8s_node2 = true
  }
}
