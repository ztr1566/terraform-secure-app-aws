output "public_alb_dns" {
  value = aws_lb.public.dns_name
}

output "internal_alb_dns" {
  value = aws_lb.internal.dns_name
}

output "public_alb_tg_arn" {
  value = aws_lb_target_group.public.arn
}

output "private_alb_tg_arn" {
  value = aws_lb_target_group.private.arn
}