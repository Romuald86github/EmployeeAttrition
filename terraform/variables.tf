variable "AWS_DEFAULT_REGION" {
  description = "The AWS region to deploy resources into"
  default     = "eu-north-1"  # Stockholm region
}

variable "S3_BUCKET_NAME" {
  description = "The name of the S3 bucket for storing the application package"
  default     = "attritionproject"
}

variable "AWS_ACCESS_KEY_ID" {
  description = "The AWS access key ID"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The AWS secret access key"
  type        = string
}

variable "DOCKER_IMAGE_URL" {
  description = "The URL of the Docker image"
  type        = string
}

variable "AWS_ACCOUNT_ID" {
  description = "The AWS account ID"
  type        = string
}
