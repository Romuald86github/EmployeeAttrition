#!/bin/bash

# Navigate to the app directory
cd ../app

# Zip the application files
zip -r ../terraform/app.zip .

# Navigate back to the terraform directory
cd ../terraform
