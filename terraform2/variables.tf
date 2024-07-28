variable "AWS_DEFAULT_REGION" {
  description = "AWS default region"
  type        = string
  default     = "eu-north-1"
}

variable "zip_file" {
  description = "The path to the application zip file"
  type        = string
  default     = "app.zip"
}



variable "VPC_ID" {
  description = "ID of the VPC to use for the Elastic Beanstalk environment"
  type        = string
  default     = "vpc-05cdca43df7e9fab8"
}

variable "SUBNET_IDS" {
  description = "List of subnet IDs to use for the Elastic Beanstalk environment"
  type        = list(string)
  default     = ["subnet-0824deee3cf53543e", "subnet-0c44526c62d185c59", "subnet-0c0e72ee4a3b9d28c"]
}

variable "DOCKER_IMAGE_URL" {
  description = "URL of the Docker image to use for the Elastic Beanstalk environment"
  type        = string
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID for the Flask app to access S3"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key for the Flask app to access S3"
  type        = string
}

variable "S3_BUCKET_NAME" {
  description = "Name of the S3 bucket for model artifacts"
  type        = string
  default     = "attritionproject"
}

variable "AWS_ACCOUNT_ID" {
  description = "AWS Account ID for the ECR repository"
  type        = string
}
