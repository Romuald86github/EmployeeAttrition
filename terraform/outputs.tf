output "application_name" {
  value = aws_elastic_beanstalk_application.flask_app.name
}

output "environment_name" {
  value = aws_elastic_beanstalk_environment.flask_env.name
}

output "application_version" {
  value = aws_elastic_beanstalk_application_version.flask_app_version.name
}

output "endpoint_url" {
  value = aws_elastic_beanstalk_environment.flask_env.endpoint_url
}
