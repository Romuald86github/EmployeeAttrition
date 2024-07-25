#!/bin/bash

# Navigate to the project root directory
cd ../

# Zip the application files
zip -r terraform/app.zip app/

# Navigate back to the terraform/scripts directory
cd terraform/scripts