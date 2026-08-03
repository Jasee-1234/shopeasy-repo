# Product Service - Python + Gunicorn
FROM python:3.12-slim

WORKDIR /app

# Install dependencies-Copy dependency list first so Docker can cache this layer between builds
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Environment
EXPOSE 8080

# Start with Gunicorn (gunicorn is production-grade compared to flask's dev server)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
