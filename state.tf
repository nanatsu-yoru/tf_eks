# terraform {
#     backend "s3" {
#         bucket = "tf-state"
#         key = "terraform-eks.tfstate"
#         region = "eu-west-1"
#         dynamodb_table = "tf-lock"
#     }
# }