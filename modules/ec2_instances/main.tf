resource "aws_instance" "proxy" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.ssh_key_name
  subnet_id              = var.public_subnets_ids[count.index]
  vpc_security_group_ids = [var.proxy_sg_id]

  tags = {
    Name = "${var.project_name}-proxy-${count.index + 1}"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    content = templatefile("${path.module}/proxy.conf.tftpl", {
      internal_alb_dns_name = var.internal_alb_dns_name
    })
    destination = "/home/ec2-user/proxy.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo systemctl enable nginx",
      "sudo setsebool -P httpd_can_network_connect 1",
      "sudo mv /home/ec2-user/proxy.conf /etc/nginx/conf.d/proxy.conf",
      "sudo systemctl start nginx",
    ]
  }
}

resource "aws_lb_target_group_attachment" "proxy" {
  count            = 2
  target_group_arn = var.public_alb_tg_arn
  target_id        = aws_instance.proxy[count.index].id
  port             = 80
}

resource "aws_instance" "backend" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.ssh_key_name
  subnet_id                   = var.private_subnets_ids[count.index]
  vpc_security_group_ids      = [var.backend_sg_id]
  user_data_replace_on_change = true
  user_data                   = file("${path.module}/user_data.sh")

  tags = {
    Name = "${var.project_name}-backend-${count.index + 1}"
  }

  depends_on = [aws_instance.proxy]
}

resource "aws_lb_target_group_attachment" "backend" {
  count            = 2
  target_group_arn = var.private_alb_tg_arn
  target_id        = aws_instance.backend[count.index].id
  port             = 3000
}
