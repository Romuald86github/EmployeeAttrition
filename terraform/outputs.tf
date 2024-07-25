output "application_name" {
  value = data.aws_elastic_beanstalk_application.flask_app.name
}

output "environment_name" {
  value = aws_elastic_beanstalk_environment.flask_env.name
}

output "application_version" {
  value = aws_elastic_beanstalk_application_version.flask_app_version.name
}
