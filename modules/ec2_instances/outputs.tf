output "proxy_public_ips" {
  value = aws_instance.proxy[*].public_ip
}