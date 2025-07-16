output "proxy_sg_id" {
  description = "The ID of the proxy security group."
  value       = aws_security_group.proxy.id
}

output "backend_sg_id" {
  description = "The ID of the backend security group."
  value       = aws_security_group.backend.id
}

# --- FIX ---
# Add this output to expose the internal ALB's security group ID.
output "internal_alb_sg_id" {
  description = "The ID of the internal ALB security group."
  value       = aws_security_group.internal_alb.id
}
