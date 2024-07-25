provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

# Use the existing IAM service role for Elastic Beanstalk
data "aws_iam_role" "eb_service_role" {
  name = "eb-service-role"
}

# S3 bucket for application deployment
data "aws_s3_bucket" "app_bucket" {
  bucket = var.S3_BUCKET_NAME
}

resource "aws_s3_bucket_object" "flask_app" {
  bucket = data.aws_s3_bucket.app_bucket.bucket
  key    = "flask_app.zip"
  source = "${path.module}/app.zip"  # Correct path to app.zip
  acl    = "private"
}

resource "aws_elastic_beanstalk_application" "attrition_app" {
  name        = "attrition-app"
  description = "Elastic Beanstalk Application for the Attrition project"
}

resource "aws_elastic_beanstalk_application_version" "attrition_app_version" {
  application = aws_elastic_beanstalk_application.attrition_app.name
  version_label = "v1"
  bucket        = data.aws_s3_bucket.app_bucket.bucket
  key           = aws_s3_bucket_object.flask_app.key
  description   = "Initial version of the Attrition application"
}

resource "aws_elastic_beanstalk_environment" "attrition_env" {
  name                = "attrition-app-env"
  application         = aws_elastic_beanstalk_application.attrition_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.6 running Docker"

  setting {
    namespace = "aws:elasticbeanstalk:container:docker"
    name      = "DockerImage"
    value     = "flask-app:latest"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = data.aws_iam_role.eb_service_role.arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  version_label = aws_elastic_beanstalk_application_version.attrition_app_version.version_label
  depends_on    = [aws_s3_bucket_object.flask_app]
}

# Attach existing policies to the IAM role
resource "aws_iam_role_policy_attachment" "eb_instance_profile_policy_attachment" {
  role       = data.aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "eb_instance_profile_policy_attachment2" {
  role       = data.aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_instance_profile_policy_attachment3" {
  role       = data.aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkMulticontainerDocker"
}
