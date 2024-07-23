output "s3_bucket_name" {
  description = "Name of the S3 bucket for model artifacts"
  value       = var.S3_BUCKET_NAME
}

output "elastic_beanstalk_environment_name" {
  description = "Name of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.my_flask_app_env.name
}

output "elastic_beanstalk_environment_url" {
  description = "URL of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.my_flask_app_env.cname
}