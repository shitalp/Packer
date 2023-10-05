variable "instance_info" {
  type = object({
    ami_name        = string
    instance_type   = string
    region          = string
    source_ami_name = string
    ssh_username    = string
    tags            = map(string)
    packages        = list(string)
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

#variable "aws_access_key" {
#  description = "AWS Access Key ID"
#}

#variable "aws_secret_key" {
#  description = "AWS Secret Access Key"
#}

#variable "aws_session_token" {
#  description = "AWS Session Token"
#}

source "amazon-ebs" "amazon-linux2" {
  ami_name              = var.instance_info.ami_name
  instance_type         = var.instance_info.instance_type
  region                = var.instance_info.region
#  access_key            = var.aws_access_key
#  secret_key            = var.aws_secret_key
#  token                 = var.aws_session_token
  force_deregister      = true
  force_delete_snapshot = true
  //source_ami_filter {
    //filters = {
     // name                = var.instance_info.source_ami_name
     // root-device-type    = "ebs"
      //virtualization-type = "hvm"
    //}
    //most_recent = true
    //owners      = ["137112412989"]
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
    inline = [
      "sudo yum -y update",
      "sudo yum install -y python"
    ]
  }
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    user = "ec2-user"
    extra_arguments = [ "--scp-extra-args", "'-O'" ]
  }
}
