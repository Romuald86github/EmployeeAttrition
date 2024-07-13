import os
import boto3
import pandas as pd
import pickle

# Set up AWS credentials
aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
aws_region = os.getenv('AWS_DEFAULT_REGION')

# Set the S3 bucket and path
bucket_name = "attritionproject"
artifact_path = "attrition/artifacts"
artifact_uri = f"s3://{bucket_name}/{artifact_path}"

# Initialize boto3 client
s3_client = boto3.client(
    's3',
    region_name=aws_region,
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key
)

# Load the preprocessing pipeline from S3
preprocessing_pipeline_path = f"s3://{bucket_name}/{artifact_path}/preprocessing_pipeline.pkl"
local_pipeline_path = os.path.join(".", "preprocessing_pipeline.pkl")
s3_client.download_file(bucket_name, f"{artifact_path}/preprocessing_pipeline.pkl", local_pipeline_path)

with open(local_pipeline_path, 'rb') as f:
    preprocessing_pipeline = pickle.load(f)

# Check the type and constituents of the preprocessing pipeline
print(f"Type of preprocessing_pipeline: {type(preprocessing_pipeline)}")
print(f"Named steps in preprocessing_pipeline: {preprocessing_pipeline.named_steps}")

# Create a sample input data
sample_data = {
    "DailyRate": 1102,
    "DistanceFromHome": 1,
    "EnvironmentSatisfaction": 2,
    "JobInvolvement": 2,
    "JobSatisfaction": 3,
    "MaritalStatus": "Single",
    "NumCompaniesWorked": 8,
    "OverTime": "Yes",
    "StockOptionLevel": 0,
    "TotalWorkingYears": 8,
    "TrainingTimesLastYear": 0,
    "WorkLifeBalance": 1,
    "YearsAtCompany": 6
}

# Convert the sample data to a pandas DataFrame
sample_df = pd.DataFrame([sample_data])

# Test the preprocessing pipeline on the sample data
transformed_data = preprocessing_pipeline.transform(sample_df)
print(f"Transformed data shape: {transformed_data.shape}")