provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

resource "aws_s3_bucket" "model_artifacts" {
  bucket = var.S3_BUCKET_NAME
  acl    = "private"

  versioning {
    enabled = false
  }
}

resource "aws_cloudwatch_log_group" "eb_logs" {
  name = "my-app-logs"
}

resource "aws_elastic_beanstalk_application" "my_app" {
  name = "my-app"
}

resource "aws_elastic_beanstalk_environment" "my_app_env" {
  name                = "my-app-env"
  application         = aws_elastic_beanstalk_application.my_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.6 running Python 3.8"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.EC2_KEY_PAIR_NAME
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.VPC_ID
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = var.SUBNET_IDS
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ContainerPort"
    value     = "5010"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "DockerRunArgs"
    value     = "-p 5010:5010"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "DockerConfigurationSource"
    value     = "DockerRunArgs"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "DockerRunImage"
    value     = var.DOCKER_IMAGE_URL
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
    name      = "S3_BUCKET_NAME"
    value     = var.S3_BUCKET_NAME
  }
}