import requests
import json

# Set the endpoint URL
url = "http://10.0.91.30:5008/predict"

# Sample input data
input_data = {
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

# Convert the input data to JSON
json_data = json.dumps(input_data)

# Send a POST request to the Flask app
response = requests.post(url, data=json_data, headers={'Content-Type': 'application/json'})

# Print the prediction
print(response.json())