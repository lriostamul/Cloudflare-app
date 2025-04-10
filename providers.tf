terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"  
      version = "~> 4.0"                
    }
  }

  required_version = ">= 1.3"
}

provider "aws" {
  region = "us-east-2" 
}


provider "cloudflare" {
  api_token = "MZ07ljy20wEzdbFpSDSq2NVGErdM_CE8h3SAxLtG"     
}
