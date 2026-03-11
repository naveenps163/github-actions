variable "instance_count" {
  default = 1
}

resource "aws_instance" "my_ec2" {
  count = var.instance_count
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"

  tags = {
    Name = "github-actions-ec2-${count.index}"
  }
}