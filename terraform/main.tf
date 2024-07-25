provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

# Use the existing IAM service role for Elastic Beanstalk
data "aws_iam_role" "eb_service_role" {
  name = "eb-service-role"
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = var.S3_BUCKET_NAME
  acl    = "private"
}

resource "aws_s3_bucket_object" "flask_app" {
  bucket = aws_s3_bucket.app_bucket.bucket
  key    = "flask_app.zip"
  source = "${path.module}/app.zip"  # The zip file created by the script
}

resource "aws_elastic_beanstalk_application" "flask_app" {
  name        = "my-flask-app"
  description = "Flask application"
}

resource "aws_elastic_beanstalk_application_version" "flask_app_version" {
  name        = "flask-app-version"
  application = aws_elastic_beanstalk_application.flask_app.name
  bucket      = aws_s3_bucket.app_bucket.bucket
  key         = "flask_app.zip"
  description = "Version of Flask app"
}

resource "aws_elastic_beanstalk_environment" "flask_env" {
  name                = "my-flask-app-env"
  application         = aws_elastic_beanstalk_application.flask_app.name
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

resource "aws_iam_policy" "eb_instance_profile_policy" {
  name        = "eb-instance-profile-policy"
  description = "Policy for EC2 instances in Elastic Beanstalk environment"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.S3_BUCKET_NAME}/*",
          "arn:aws:s3:::${var.S3_BUCKET_NAME}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eb_instance_profile_policy_attachment" {
  role       = data.aws_iam_role.eb_service_role.name
  policy_arn = aws_iam_policy.eb_instance_profile_policy.arn
}
