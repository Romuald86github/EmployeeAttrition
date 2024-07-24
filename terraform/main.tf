provider "aws" {
  region = var.AWS_DEFAULT_REGION
}


# Create the Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "my-flask-app" {
  name = "my-flask-app"
}

# Create the Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "my-flask-app-env" {
  name                = "my-flask-app-env"
  application         = aws_elastic_beanstalk_application.my-flask-app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running Python 3.9"

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
    name      = "S3_BUCKET_NAME"
    value     = var.S3_BUCKET_NAME
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DOCKER_IMAGE_URL"
    value     = var.DOCKER_IMAGE_URL
  }
}
