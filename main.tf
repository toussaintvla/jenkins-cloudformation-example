provider "aws" {
    region = "us-east-1"
  #   assume_role {
  #   role_arn     = "arn:aws:iam::234193177348:role/OrganizationAccountAccessRole"
  # }
}

resource "aws_network_interface" "foo" {
  subnet_id   = "${var.subnet_id}"
  private_ips = ["${var.ip}"]

  tags = {
    Name = "vlad_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-062f7200baf2fa504" # us-east-1
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = "${aws_network_interface.foo.id}"
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags {
    Name = "vlad_terraform_instance"
  }
}