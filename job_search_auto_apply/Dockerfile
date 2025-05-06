# Use official Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy everything
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port for web app
EXPOSE 5000

# Set default command to run Flask app
CMD ["python", "web_app.py"]

# switch to FastAPI by uncommenting the following line and commenting the Flask line above.
# CMD ["uvicorn", "fastapi_app:app", "--host", "0.0.0.0", "--port", "5000"]
