variable "project_name" {
  type = string
}
variable "ami_id" {
  type = string
}
variable "ssh_key_name" {
  type = string
}
variable "private_key_path" {
  description = "Path to the private SSH key file."
  type        = string
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
variable "public_alb_tg_arn" {
  type = string
}
variable "private_alb_tg_arn" {
  type = string
}
variable "internal_alb_dns_name" {
  type = string
}

variable "app_path" {
  description = "Path to the application source code directory."
  type        = string
}