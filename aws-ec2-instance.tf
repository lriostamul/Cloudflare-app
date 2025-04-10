variable "cloudflare_ip_ranges" {
  type = map(string)
  default = {
    "range_1"  = "173.245.48.0/20"
    "range_2"  = "103.21.244.0/22"
    "range_3"  = "103.22.200.0/22"
    "range_4"  = "103.31.4.0/22"
    "range_5"  = "141.101.64.0/18"
    "range_6"  = "108.162.192.0/18"
    "range_7"  = "190.93.240.0/20"
    "range_8"  = "188.114.96.0/20"
    "range_9"  = "197.234.240.0/22"
    "range_10" = "198.41.128.0/17"
    "range_11" = "162.158.0.0/15"
    "range_12" = "104.16.0.0/13"
    "range_13" = "104.24.0.0/14"
    "range_14" = "172.64.0.0/13"
    "range_15" = "131.0.72.0/22"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "cloudflare-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "web_app_sg" {
  name        = "security-group-for-ec2"
  description = "Allow HTTPS"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "cloudflare_ingress" {
  for_each = var.cloudflare_ip_ranges

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.web_app_sg.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

resource "aws_instance" "ubuntu_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro" 
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.web_app_sg.id]

  tags = {
    Name = "cloudflare-Terraform-Instance"
  }
}
