import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from imblearn.over_sampling import RandomOverSampler
from scipy.stats import yeojohnson
import pickle

def load_data():
    data = pd.read_csv("data/processed/selected_data.csv")
    target_column = "Attrition"
    return data, target_column

def preprocess_data(data, target_column):
    X = data.drop(columns=[target_column])
    y = data[target_column]

    # Remove skewness
    columns_to_transform = ['DistanceFromHome', 'TotalWorkingYears', 'YearsAtCompany']
    for col in columns_to_transform:
        X[col], _ = yeojohnson(X[col])

    # Encode target
    le = LabelEncoder()
    y = le.fit_transform(y)

    # Encode or get_dummies for categorical columns
    categorical_cols = X.select_dtypes(include='object').columns
    X = pd.get_dummies(X, columns=categorical_cols, drop_first=True)

    # Balance target classes
    ros = RandomOverSampler(random_state=42)
    X, y = ros.fit_resample(X, y)

    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.4, random_state=42)
    X_val, X_test, y_val, y_test = train_test_split(X_test, y_test, test_size=0.5, random_state=42)

    # Scale data
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_val = scaler.transform(X_val)
    X_test = scaler.transform(X_test)

    # Ensure the directory exists
    output_dir = 'data/processed'
    os.makedirs(output_dir, exist_ok=True)

    # Save the individual datasets
    pd.to_pickle(X_train, os.path.join(output_dir, 'X_train.pkl'))
    pd.to_pickle(X_val, os.path.join(output_dir, 'X_val.pkl'))
    pd.to_pickle(X_test, os.path.join(output_dir, 'X_test.pkl'))
    pd.to_pickle(y_train, os.path.join(output_dir, 'y_train.pkl'))
    pd.to_pickle(y_val, os.path.join(output_dir, 'y_val.pkl'))
    pd.to_pickle(y_test, os.path.join(output_dir, 'y_test.pkl'))

    # Save the preprocessed data as a single file
    preprocessed_data = (X_train, X_val, X_test, y_train, y_val, y_test)
    pd.to_pickle(preprocessed_data, os.path.join(output_dir, 'preprocessed_data.pkl'))

if __name__ == "__main__":
    data, target_column = load_data()
    preprocess_data(data, target_column)
