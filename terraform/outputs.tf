output "application_name" {
  value = aws_elastic_beanstalk_application.attrition_app.name
}

output "environment_name" {
  value = aws_elastic_beanstalk_environment.attrition_env.name
}

output "s3_bucket" {
  value = data.aws_s3_bucket.app_bucket.bucket
}
