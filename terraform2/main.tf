provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

provider "local" {}

# Use the existing IAM service role for Elastic Beanstalk
data "aws_iam_role" "eb_service_role" {
  name = "eb-service-role"
}

# Create the Elastic Beanstalk application (if it doesn't exist)
resource "aws_elastic_beanstalk_application" "attrition-app1" {
  name = "attrition-app1"
}

# Read the application ZIP file content
data "local_file" "app_zip" {
  filename = "${path.module}/${var.zip_file}"
}

# Upload the application ZIP file to S3
resource "aws_s3_object" "app_zip" {
  bucket = var.S3_BUCKET_NAME
  key    = var.zip_file
  source = data.local_file.app_zip.filename
  etag   = filemd5(data.local_file.app_zip.filename)
}

# Create the Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "attrition-app1-env" {
  name                = "attrition-app1-env"
  application         = aws_elastic_beanstalk_application.attrition-app1.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running Python 3.9"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "eb-instance-profile"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.VPC_ID
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.SUBNET_IDS)
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:proxy"
    name      = "ProxyServer"
    value     = "nginx"
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
}