terraform {
  backend "s3" {
    bucket = "new123456"      # Replace with your actual S3 bucket
    key    = "project/terraform.tfstate"
    region = "eu-central-1"              # Replace with your AWS region
  }
}
