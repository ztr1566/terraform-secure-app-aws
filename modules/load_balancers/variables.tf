variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets_ids" {
  type = list(string)
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "proxy_sg_id" {
  type = string
}

variable "backend_sg_id" {
  type = string
}

# --- FIX ---
# Add this variable to accept the internal ALB's security group ID.
variable "internal_alb_sg_id" {
  description = "The ID of the security group for the internal ALB."
  type        = string
}
