# Use a base Python image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask app code (entire app directory)
COPY app /app

# Expose the port your Flask app is running on
EXPOSE 5010

# Set the command to run your Flask app using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5010", "application:app"]