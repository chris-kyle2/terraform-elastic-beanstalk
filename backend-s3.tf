terraform {
  backend "s3" {
    bucket = "backend-s3-bucket-11"
    key    = "backend-s3-bucket-11/backend"
    region = "us-east-1"
  }
}