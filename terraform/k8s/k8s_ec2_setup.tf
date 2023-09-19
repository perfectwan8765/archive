terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" 
      version = "~> 4.16" 
    }
  }

  required_version = ">= 1.2.0" 
}

provider "aws" {
  region = "ap-northeast-2" 
}

variable "nodes" {
  type   = map(object({
    name = string
    type = string
    docker_size = number
    volume_size = number
    public_ip = bool
    private_ip = string
  }))
  default = {
    "k8smaster" = {
      name = "k8smaster" 
      type = "t3.large" 
      size = 40
      volume_size = 0
      public_ip = true
      private_ip = "172.31.36.101"
    },
    "k8sworker1" = {
      name = "k8sworker1" 
      type = "t3.xlarge" 
      docker_size = 40
      volume_size = 100
      public_ip = false
      private_ip = "172.31.36.102"
    },
    "k8sworker2" = {
      name = "k8sworker2" 
      type = "t3.xlarge" 
      docker_size = 40
      volume_size = 100
      public_ip = false
      private_ip = "172.31.36.103"
    },
    "k8sworker3" = {
      name = "k8sworker3" 
      type = "t3.xlarge" 
      docker_size = 40
      volume_size = 100
      public_ip = false
      private_ip = "172.31.36.104"
    }
  }
}

resource "aws_network_interface" "enis" {
  for_each = var.nodes

  subnet_id = "subnet-f06d9fbf"
  private_ips = ["${each.value.private_ip}"]
  security_groups = [
    "sg-7936aa07",
    "sg-01b44ac4851bcf474"
  ]
}

resource "aws_instance" "instances" {
  for_each = var.nodes

  availability_zone = "ap-northeast-2c" 
  ami               = "ami-0c9c942bd7bf113a2" # ubuntu 22.04 LTS
  instance_type     = each.value.type
  key_name          = "coxspace-teat" 
  user_data         = file("./user-data/node-install.sh")

  root_block_device {
    volume_type = "gp3" 
    volume_size = 10 # GiB
  }

  network_interface {
    network_interface_id = aws_network_interface.enis[each.value.name].id
    device_index = 0
  }

  tags = {
    Name = each.value.name
    provider = "terraform" 
  }
}

resource "aws_ebs_volume" "docker_volumes" {
  for_each = var.nodes

  availability_zone = "ap-northeast-2c" 
  size = each.value.docker_size
  type = "gp3" 

  tags = {
    Name = "${each.value.name}-vol" 
    provider = "terraform" 
  }
}

resource "aws_volume_attachment" "docker_attachements" {
  for_each = var.nodes

  device_name = "/dev/sdh" 
  volume_id   = aws_ebs_volume.volumes[each.value.name].id
  instance_id = aws_instance.instances[each.value.name].id
}

resource "aws_ebs_volume" "data_volumes" {
  for_each = {
    for name, node in var.nodes : name => node
    if node.volume_size != 0
  }

  availability_zone = "ap-northeast-2c"
  size = each.value.volume_size
  type = "gp3"

  tags = {
    Name = "${each.value.name}-data-vol"
    Provider = "terraform"
    Group = "k8scluster"
  }
}

resource "aws_volume_attachment" "data_attachements" {
  for_each = {
    for name, node in var.nodes : name => node
    if node.volume_size != 0
  }

  device_name = "/dev/sdj"
  volume_id   = aws_ebs_volume.data_volumes[each.value.name].id
  instance_id = aws_instance.instances[each.value.name].id
}

resource "aws_eip" "master_ip" {
  for_each = {
    for name, node in var.nodes : name => node
    if node.public_ip == true
  }
  instance = aws_instance.instances["k8smaster"].id
  vpc      = true

  tags = {
    Name     = "k8smaster_ip" 
    provider = "terraform" 
  }
}
