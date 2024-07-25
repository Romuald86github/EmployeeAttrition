#!/bin/bash

# Create application zip file
./create_zip.sh

# Initialize Terraform
terraform init

# Apply Terraform configuration
terraform apply -auto-approve
