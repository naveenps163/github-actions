terraform {
  backend "s3" {
    bucket = "naveen-terraform-state-bucket123"
    key    = "ec2/terraform.tfstate"
    region = "ap-south-1"
  }
}