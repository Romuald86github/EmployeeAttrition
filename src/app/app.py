import os
import boto3
import joblib
import pickle
from flask import Flask, request, jsonify
import pandas as pd
from sklearn.preprocessing import FunctionTransformer

app = Flask(__name__)

# Set the S3 bucket and path
bucket_name = "attritionproject"
artifact_path = "attrition/artifacts"

# Ensure AWS credentials are set in the environment
aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
aws_region = os.getenv('AWS_DEFAULT_REGION')

# Initialize boto3 client
s3_client = boto3.client(
    's3',
    region_name=aws_region,
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key
)

def download_from_s3(bucket_name, key, download_path):
    s3_client.download_file(bucket_name, key, download_path)

# Define remove_skewness function
def remove_skewness(X):
    columns_to_transform = ['DistanceFromHome', 'TotalWorkingYears', 'YearsAtCompany']
    for col in columns_to_transform:
        X[col], _ = yeojohnson(X[col])
    return X

# Download and load the best model from S3
model_key = f"{artifact_path}/best_model.pkl"
model_download_path = "best_model.pkl"
download_from_s3(bucket_name, model_key, model_download_path)
with open(model_download_path, 'rb') as f:
    model = pickle.load(f)

# Download and load the preprocessing pipeline from S3
pipeline_key = f"{artifact_path}/preprocessing_pipeline.pkl"
pipeline_download_path = "preprocessing_pipeline.pkl"
download_from_s3(bucket_name, pipeline_key, pipeline_download_path)

# Ensure remove_skewness is in the current namespace
preprocessing_pipeline = joblib.load(pipeline_download_path, globals={'remove_skewness': remove_skewness})

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    df = pd.DataFrame([data])
    X_preprocessed = preprocessing_pipeline.transform(df)
    prediction = model.predict(X_preprocessed)
    return jsonify({'prediction': int(prediction[0])})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
