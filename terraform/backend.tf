terraform {
  backend "s3" {
    bucket = "xvwaydgyeqagqagqagcbuakqwe"
    key = "dev/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}