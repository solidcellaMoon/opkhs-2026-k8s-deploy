output "instance_private_ips" {
  description = "Map of instance names to their private IP addresses"
  value       = { for k, inst in aws_instance.nodes : k => inst.private_ip }
}

output "instance_ids" {
  description = "Map of instance names to EC2 instance IDs"
  value       = { for k, inst in aws_instance.nodes : k => inst.id }
}

output "instance_public_ips" {
  description = "Map of instance names to their public IP addresses"
  value       = { for k, inst in aws_instance.nodes : k => inst.public_ip }
}
