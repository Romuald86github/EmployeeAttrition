#!/bin/bash

#!/bin/bash

# Navigate to the terraform directory
cd ../terraform

# Initialize Terraform
terraform init

# Apply Terraform configuration
terraform apply -auto-approve
