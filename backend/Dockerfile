FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

EXPOSE 5000

# Start the Flask app
CMD ["flask", "run", "--host=0.0.0.0"]
