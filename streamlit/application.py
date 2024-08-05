import os
import boto3
import pickle
import pandas as pd
import streamlit as st

# Set up AWS credentials
aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
aws_region = 'eu-north-1'

# Set the S3 bucket and path
bucket_name = "attritionproject"
artifact_path = "attrition/artifacts"

# Initialize boto3 client
s3_client = boto3.client(
    's3',
    region_name=aws_region,
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key
)

# Load the best model from S3
model_path = f"s3://{bucket_name}/{artifact_path}/best_model.pkl"
local_model_path = os.path.join(".", "best_model.pkl")
s3_client.download_file(bucket_name, f"{artifact_path}/best_model.pkl", local_model_path)

with open(local_model_path, 'rb') as f:
    model = pickle.load(f)

# Load the preprocessing pipeline from S3
preprocessing_pipeline_path = f"s3://{bucket_name}/{artifact_path}/preprocessing_pipeline.pkl"
local_pipeline_path = os.path.join(".", "preprocessing_pipeline.pkl")
s3_client.download_file(bucket_name, f"{artifact_path}/preprocessing_pipeline.pkl", local_pipeline_path)

with open(local_pipeline_path, 'rb') as f:
    preprocessing_pipeline = pickle.load(f)

# Define Streamlit app
def run_streamlit_app():
    st.set_page_config(page_title="Attrition Prediction App", page_icon=":bar_chart:")
    st.title("Attrition Prediction App")

    # Input features
    daily_rate = st.number_input("Daily Rate", min_value=0, max_value=100000, step=1, value=0)
    distance_from_home = st.number_input("Distance from Home", min_value=0, max_value=50, step=1, value=0)
    environment_satisfaction = st.selectbox("Environment Satisfaction", options=[1, 2, 3, 4], index=0)
    job_involvement = st.selectbox("Job Involvement", options=[1, 2, 3, 4], index=0)
    job_satisfaction = st.selectbox("Job Satisfaction", options=[1, 2, 3, 4], index=0)
    marital_status = st.selectbox("Marital Status", options=['Single', 'Married', 'Divorced'], index=0)
    num_companies_worked = st.number_input("Number of Companies Worked", min_value=0, max_value=20, step=1, value=0)
    overtime = st.selectbox("Overtime", options=['Yes', 'No'], index=0)
    stock_option_level = st.number_input("Stock Option Level", min_value=0, max_value=3, step=1, value=0)
    total_working_years = st.number_input("Total Working Years", min_value=0, max_value=50, step=1, value=0)
    training_times_last_year = st.number_input("Training Times Last Year", min_value=0, max_value=10, step=1, value=0)
    work_life_balance = st.selectbox("Work-Life Balance", options=[1, 2, 3, 4], index=0)
    years_at_company = st.number_input("Years at Company", min_value=0, max_value=50, step=1, value=0)

    # Create a dictionary with the input features
    input_data = {
        'DailyRate': daily_rate,
        'DistanceFromHome': distance_from_home,
        'EnvironmentSatisfaction': environment_satisfaction,
        'JobInvolvement': job_involvement,
        'JobSatisfaction': job_satisfaction,
        'MaritalStatus': marital_status,
        'NumCompaniesWorked': num_companies_worked,
        'OverTime': overtime,
        'StockOptionLevel': stock_option_level,
        'TotalWorkingYears': total_working_years,
        'TrainingTimesLastYear': training_times_last_year,
        'WorkLifeBalance': work_life_balance,
        'YearsAtCompany': years_at_company
    }

    # Make prediction
    if st.button("Predict"):
        try:
            df = pd.DataFrame([input_data])
            X_preprocessed = preprocessing_pipeline.transform(df)
            prediction = model.predict(X_preprocessed)
            if prediction == 0:
                st.success("The employee is not likely to leave the company.")
            else:
                st.error("The employee is likely to leave the company.")
        except Exception as e:
            st.error(f"Error making prediction: {e}")

if __name__ == "__main__":
    run_streamlit_app()
