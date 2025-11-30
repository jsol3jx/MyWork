resource "aws_security_group" "alb_sg" {
  name        = "${var.ecs_name}-${var.env}-alb-sg-${random_string.alb_sg.result}"
  description = "Security group restricting incoming traffic to Squire"

  vpc_id = var.vpc_id

  ingress {
    description     = "Allowing inbound https traffic to whitelisted Cloudflare IPv4 ips"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = ["pl-0180b01926fb27e23"] # CloudFlare IPv4 managed prefix list
  }
  ingress {
    description     = "Allowing inbound https traffic to whitelisted Cloudflare IPv6 ips"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = ["pl-05ce8b93c2a7250b6"] # CloudFlare IPv6 managed prefix list
  }
  ingress {
    description     = "Allowing inbound http traffic to whitelisted Cloudflare IPv4 ips"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = ["pl-0180b01926fb27e23"] # CloudFlare IPv4 managed prefix list
  }
  ingress {
    description     = "Allowing inbound http traffic to whitelisted Cloudflare IPv6 ips"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = ["pl-05ce8b93c2a7250b6"] # CloudFlare IPv6 managed prefix list
  }

  egress {
    description      = "Allowing all outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.ecs_name}-${var.env}-ecs-sg-${random_string.ecs_sg.result}"
  description = "Security group restricting incoming traffic to ECS"

  vpc_id = var.vpc_id

  ingress {
    description     = "Allowing inbound traffic from white listed IPs"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description      = "Allowing all outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_string" "alb_sg" {
  length  = 3
  upper   = false
  lower   = true
  special = false
}

resource "random_string" "ecs_sg" {
  length  = 3
  upper   = false
  lower   = true
  special = false
}