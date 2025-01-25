# using s3 for state storage and locking with dynamo db
terraform {
    backend "s3" {
      bucket = "devops-delight-terraform"
      key = "terraform-practice"
      region = "us-east-1"
      dynamodb_table = "terraform-practice"
      encrypt = true
    }
}

