# Multi-stage Dockerfile for B3 Trading Platform
# This Dockerfile can build different services based on target stage

# Base Python image for backend services
FROM python:3.11-slim as python-base
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Backend build stage
FROM python-base as backend
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ .
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]

# Frontend build stage
FROM node:lts-alpine as frontend
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY frontend/package*.json ./
RUN npm install --production --silent && mv node_modules ../
COPY frontend/ .
EXPOSE 3000
RUN chown -R node /usr/src/app
USER node
CMD ["npm", "start"]

# Market data service build stage  
FROM python-base as market-data
WORKDIR /app
COPY services/market-data/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY services/market-data/ .
CMD ["python", "main.py"]

# Default stage (backend)
FROM backend as default