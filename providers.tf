provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::772031827187:role/AbrigoCICDAdmin"
  }

  default_tags {
    tags = {
      "product"     = "lz"
      "application" = "networks"
      "environment" = "DEV"
      "owner"       = "dan.nugent@abrigo.com"
    }
  }
}


#
# Providers used to tag RAM shared resources - VPC and subnet.  Do not use default tags
#
provider "aws" {
  alias  = "sandbox"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::673052121367:role/AbrigoCICDAdmin"
  }

  default_tags {
    tags = {
      "product"     = "lz"
      "application" = "networks"
      "environment" = "DEV"
      "owner"       = "dan.nugent@abrigo.com"
    }
  }
}
