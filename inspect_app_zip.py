import zipfile

with zipfile.ZipFile('app.zip', 'r') as zip_file:
    print(zip_file.namelist())