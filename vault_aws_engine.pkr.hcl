packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "vault_address" {
  type    = string
  default = "${env("VAULT_ADDR")}"
}

variable "vault_token" {
  type    = string
  sensitive = true
  default = "${env("VAULT_TOKEN")}"
}

locals {
    API_KEY = vault("secret/data/data/myapp", "apiKey")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-{{timestamp}}"
  instance_type = "t3.micro"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
    }
  ssh_username = "ubuntu"
  tags = {
    "Name"        = "packer-ubuntu2004"
    "Environment" = "Development"
    "OS_Version"  = "Ubuntu 20.04"
  }

  vault_aws_engine {
    name = "my-ec2-role"
    engine_name = "aws"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [ "echo 'This is an AMI created by Hashicorp Packer!!'" ]
  }

  provisioner "shell" {
    inline = [ "echo 'API_KEY secret value is ${local.API_KEY}'" ]
  }
}