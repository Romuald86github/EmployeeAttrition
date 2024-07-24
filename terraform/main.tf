provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

# Fetch availability zones in eu-north-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Use the existing VPC
data "aws_vpc" "main" {
  id = var.VPC_ID
}

# Create subnets
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
}

# Create internet gateway if not exists
resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.main.id
}

# Create route table
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Create security group
resource "aws_security_group" "eb_sg" {
  name        = "eb_sg"
  description = "Security group for Elastic Beanstalk environment"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eb-sg"
  }
}

# Use the existing IAM service role for Elastic Beanstalk
data "aws_iam_role" "eb_service_role" {
  name = "eb-service-role"
}

# Create the Elastic Beanstalk application (if it doesn't exist)
resource "aws_elastic_beanstalk_application" "my-flask-app" {
  name = "my-flask-app"
}

# Create the Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "my-flask-app-env" {
  name                = "my-flask-app-env"
  application         = aws_elastic_beanstalk_application.my-flask-app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.6 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.EC2_KEY_PAIR_NAME
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.main.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", aws_subnet.public.*.id)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_sg.id
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

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EC2_KEY_PAIR_PATH"
    value     = var.EC2_KEY_PAIR_PATH
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
