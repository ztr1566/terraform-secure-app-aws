output "public_alb_dns_name" {
  description = "The DNS name of the public Application Load Balancer."
  value       = module.load_balancers.public_alb_dns
}

output "proxy_instance_public_ips" {
  description = "Public IPs of the Nginx proxy instances."
  value       = module.ec2_instances.proxy_public_ips
}