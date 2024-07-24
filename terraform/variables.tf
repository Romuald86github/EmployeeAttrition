variable "AWS_DEFAULT_REGION" {
  description = "AWS default region"
  type        = string
  default     = "eu-north-1"
}

variable "EC2_KEY_PAIR_NAME" {
  description = "Name of the EC2 key pair to use for the Elastic Beanstalk environment"
  type        = string
  default     = "WRomyAS"
}

variable "EC2_KEY_PAIR_PATH" {
  description = "Path to the EC2 key pair file to use for the Elastic Beanstalk environment"
  type        = string
}

variable "VPC_ID" {
  description = "ID of the VPC to use for the Elastic Beanstalk environment"
  type        = string
  default     = "vpc-05cdca43df7e9fab8"
}

variable "SUBNET_IDS" {
  description = "List of subnet IDs to use for the Elastic Beanstalk environment"
  type        = list(string)
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
