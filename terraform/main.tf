provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

# Data source for existing IAM role
data "aws_iam_role" "eb_service_role" {
  name = "eb-service-role"
}

# Data source for existing S3 bucket
data "aws_s3_bucket" "app_bucket" {
  bucket = var.S3_BUCKET_NAME
}

# Upload the application zip file to S3
resource "aws_s3_bucket_object" "flask_app" {
  bucket = data.aws_s3_bucket.app_bucket.bucket
  key    = "flask_app.zip"
  source = "${path.module}/app.zip"  # Correct path to app.zip
  acl    = "private"
}

# Create a new Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "attrition_app" {
  name        = "attrition-app"
  description = "Elastic Beanstalk Application for the Attrition project"
}

# Define the application version
resource "aws_elastic_beanstalk_application_version" "attrition_app_version" {
  application = aws_elastic_beanstalk_application.attrition_app.name
  name        = "v1"  # Name of the version
  bucket      = data.aws_s3_bucket.app_bucket.bucket
  key         = aws_s3_bucket_object.flask_app.key
  description = "Initial version of the Attrition application"
}

# Create an Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "attrition_env" {
  name                = "attrition-app-env"
  application         = aws_elastic_beanstalk_application.attrition_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running Python 3.9"

  setting {
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "WsgiPath"
    value     = "app:app"  # Adjust based on your Gunicorn WSGI app entry point
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "NumWorkers"
    value     = "3"  # Number of Gunicorn workers
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "GunicornApp"
    value     = "app:app"  # Adjust based on your Gunicorn WSGI app entry point
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "InstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  version_label = aws_elastic_beanstalk_application_version.attrition_app_version.name
  depends_on    = [aws_s3_bucket_object.flask_app]
}

# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "eb-instance-profile"
  role = data.aws_iam_role.eb_service_role.name
}
