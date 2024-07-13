import os
import mlflow
import mlflow.sklearn
from flask import Flask, request, jsonify
import pandas as pd
import boto3

app = Flask(__name__)

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

# Load the best model from S3
model_name = "RandomForestClassifier"
model_version = "1"
model_path = f"s3://{bucket_name}/{artifact_path}/best_model.pkl"
model = mlflow.sklearn.load_model(model_path)

# Load the preprocessing pipeline from S3
preprocessing_pipeline_path = f"s3://{bucket_name}/{artifact_path}/preprocessing_pipeline.pkl"
preprocessing_pipeline = mlflow.sklearn.load_model(preprocessing_pipeline_path)

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    df = pd.DataFrame([data])
    X_preprocessed = preprocessing_pipeline.transform(df)
    prediction = model.predict(X_preprocessed)
    return jsonify({'prediction': int(prediction[0])})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)