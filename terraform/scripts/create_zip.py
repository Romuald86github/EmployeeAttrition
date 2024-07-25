import os
import zipfile

# Specify the directory containing the application files
app_dir = "/Users/romualdchristialtcheutchoua/EmployeeAttrition/src/app"

# Specify the path where the zip file will be created
zip_dir = "/Users/romualdchristialtcheutchoua/EmployeeAttrition/terraform"
zip_filename = "app.zip"
zip_path = os.path.join(zip_dir, zip_filename)

# Create the zip file
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zip_file:
    # Walk through the directory and add files to the zip
    for root, _, files in os.walk(app_dir):
        for file in files:
            file_path = os.path.join(root, file)
            # Add the file to the zip file, maintaining the relative path
            relative_path = os.path.relpath(file_path, app_dir)
            zip_file.write(file_path, os.path.join('app', relative_path))

print(f"Zip file created: {zip_path}")
