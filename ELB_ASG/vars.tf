# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# Please fill in ytour access key and secret key below
# ---------------------------------------------------------------------------------------------------------------------

variable "access_key" {
    description = "Access key is available in IAM"
	default = ""
}
variable "secret_key" {
    description = "Secret key is available in IAM"
	default = ""
}
variable "region" {
    description = "AWS region to luanch your services"
	default = "us-east-2"
}

variable "aws_amis" {
  default = {
    us-east-1 = "ami-7d132e18" # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type in us-east-2
    us-east-2 = "ami-7d132e18"  
    us-west-1 = "ami-969ab1f6"
    us-west-2 = "ami-8803e0f0"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}