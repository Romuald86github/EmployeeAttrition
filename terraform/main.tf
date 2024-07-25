provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

# Use the existing S3 bucket
data "aws_s3_bucket" "app_bucket" {
  bucket = "attritionproject"
}

resource "aws_s3_bucket_object" "flask_app" {
  bucket = data.aws_s3_bucket.app_bucket.bucket
  key    = "flask_app.zip"
  source = "${path.module}/app.zip"
}

# Use the existing Elastic Beanstalk application
data "aws_elastic_beanstalk_application" "flask_app" {
  name = "attrition-app"
}

resource "aws_elastic_beanstalk_application_version" "flask_app_version" {
  name        = "attrition-app-version"
  application = data.aws_elastic_beanstalk_application.flask_app.name
  bucket      = data.aws_s3_bucket.app_bucket.bucket
  key         = "flask_app.zip"
  description = "Version of Attrition app"
}

resource "aws_elastic_beanstalk_environment" "flask_env" {
  name                = "attrition-app-env"
  application         = data.aws_elastic_beanstalk_application.flask_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running Python 3.9"

  setting {
    namespace = "aws:elasticbeanstalk:environment:proxy"
    name      = "ProxyServer"
    value     = "nginx"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:proxy:staticfiles"
    name      = "/static/"
    value     = "/var/app/current/static/"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_ACCESS_KEY_ID"
    value     = var.AWS_ACCESS_KEY_ID
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_SECRET_ACCESS_KEY"
    value     = var.AWS_SECRET_ACCESS_KEY
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DEFAULT_REGION"
    value     = var.AWS_DEFAULT_REGION
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "S3_BUCKET_NAME"
    value     = var.S3_BUCKET_NAME
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCKER_IMAGE_URL"
    value     = var.DOCKER_IMAGE_URL
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_ACCOUNT_ID"
    value     = var.AWS_ACCOUNT_ID
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

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "HEALTHCHECK_URL"
    value     = "/"
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:docker"
    name      = "DockerRunCommand"
    value     = "docker run -p 5010:5010 -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION $DOCKER_IMAGE_URL"
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:docker"
    name      = "DockerImage"
    value     = var.DOCKER_IMAGE_URL
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:docker"
    name      = "DockerFile"
    value     = "../src/app/Dockerfile"
  }

  version_label = aws_elastic_beanstalk_application_version.flask_app_version.name
  depends_on    = [aws_s3_bucket_object.flask_app]
}

# Use the existing IAM service role for Elastic Beanstalk
data "aws_iam_role" "eb_service_role" {
  name = "eb-service-role"
}

# Attach existing policies to the IAM role
resource "aws_iam_role_policy_attachment" "eb_instance_profile_policy_attachment" {
  role       = data.aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::662479519742:policy/eb-instance-profile-policy"
}

resource "aws_iam_role_policy_attachment" "eb_instance_profile_policy_attachment2" {
  role       = data.aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_instance_profile_policy_attachment3" {
  role       = data.aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkMulticontainerDocker"
}
