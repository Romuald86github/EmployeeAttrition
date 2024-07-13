import requests

url = 'http://127.0.0.1:5007/predict'
data = {
    "DistanceFromHome": 5,
    "TotalWorkingYears": 10,
    "YearsAtCompany": 7,
    "JobSatisfaction": 4,
    "JobInvolvement": 3,
    "WorkLifeBalance": 2,
    "OverTime": "Yes",
    "StockOptionLevel": 1,
    "MaritalStatus": "Single",
    "NumCompaniesWorked": 2,
    "DailyRate": 800,
    "EnvironmentSatisfaction": 3
}

response = requests.post(url, json=data)
print(response.json())
