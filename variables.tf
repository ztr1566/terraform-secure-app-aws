variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "secure-app"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "ssh_key_name" {
  description = "The name of the EC2 key pair for SSH access."
  type        = string
}

variable "my_ip" {
  description = "Your local IP address for SSH access to the bastion."
  type        = string
  default     = "0.0.0.0/0"
}

variable "private_key_path" {
  description = "Path to your private SSH key file (e.g., ~/.ssh/my-key.pem)."
  type        = string
}

variable "app_path" {
  description = "Path to the application source code directory."
  type        = string
  default     = "./app"
}