variable "vpc_id" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets."
  type        = list(string)
}
