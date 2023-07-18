variable "instance_info" {
  type = object({
    ami_name        = string
    instance_type   = string
    region          = string
    source_ami_name = string
    ssh_username    = string
    tags            = map(string)
  })
}

variable "build_commands" {
  type    = list(string)
  default = []
}

variable "user_commands" {
  type    = list(string)
  default = []
}

source "amazon-ebs" "amazon-linux2" {
  ami_name              = var.instance_info.ami_name
  instance_type         = var.instance_info.instance_type
  region                = var.instance_info.region
  force_deregister      = true
  force_delete_snapshot = true
  source_ami_filter {
    filters = {
      name                = var.instance_info.source_ami_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }
  ssh_username = var.instance_info.ssh_username
  tags         = var.instance_info.tags
}

build {
  name = "Build AMI"
  sources = [
    "source.amazon-ebs.amazon-linux2"
  ]

  provisioner "shell" {
    inline = var.build_commands
  }
}
