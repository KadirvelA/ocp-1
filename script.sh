#!/bin/bash

# Clean up any previous content
echo "Cleaning up previous directories..."
rm -rf simple-quiz-app

# Create new directory structure
echo "Creating directory structure..."
mkdir -p simple-quiz-app/backend
mkdir -p simple-quiz-app/frontend
mkdir -p simple-quiz-app/k8s

# Go into the new directory
cd simple-quiz-app

# Create the README file
echo "Creating README.md..."
cat <<EOL > README.md
# Simple Quiz App

This is a simple quiz application with a backend and frontend. It uses Docker, Kubernetes, and GitHub Actions for CI/CD.

EOL

# Create the backend Dockerfile
echo "Creating backend Dockerfile..."
cat <<EOL > backend/Dockerfile
# Use official Node.js image
FROM node:16

# Set working directory
WORKDIR /app

# Install dependencies
COPY package.json ./
RUN npm install

# Copy the rest of the app code
COPY . .

# Expose backend port
EXPOSE 3000

# Command to run the backend
CMD ["node", "server.js"]
EOL

# Create the backend app (server.js)
echo "Creating backend app (server.js)..."
cat <<EOL > backend/server.js
const express = require('express');
const app = express();

app.get('/quiz', (req, res) => {
  res.json({
    question: "What is the capital of Japan?",
    options: ["Tokyo", "Beijing", "Seoul", "Bangkok"]
  });
});

const port = 3000;
app.listen(port, () => {
  console.log(\`Quiz backend is running on http://localhost:\${port}\`);
});
EOL

# Create the backend package.json
echo "Creating backend package.json..."
cat <<EOL > backend/package.json
{
  "name": "quiz-backend",
  "version": "1.0.0",
  "description": "Backend for the Simple Quiz App",
  "main": "server.js",
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOL

# Create the frontend Dockerfile
echo "Creating frontend Dockerfile..."
cat <<EOL > frontend/Dockerfile
# Use Nginx to serve the frontend
FROM nginx:alpine

# Copy static files into the Nginx container
COPY . /usr/share/nginx/html

# Expose frontend port
EXPOSE 80
EOL

# Create the frontend app (index.html)
echo "Creating frontend app (index.html)..."
cat <<EOL > frontend/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simple Quiz App</title>
</head>
<body>
    <h1>Welcome to the Quiz App!</h1>
    <div id="question"></div>
    <script>
        fetch('/quiz')
            .then(response => response.json())
            .then(data => {
                document.getElementById('question').innerHTML = data.question;
                data.options.forEach(option => {
                    const button = document.createElement('button');
                    button.textContent = option;
                    document.body.appendChild(button);
                });
            });
    </script>
</body>
</html>
EOL

# Create Kubernetes manifests for backend and frontend
echo "Creating Kubernetes manifests..."

cat <<EOL > k8s/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quiz-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: quiz-backend
  template:
    metadata:
      labels:
        app: quiz-backend
    spec:
      containers:
      - name: quiz-backend
        image: quiz-backend:latest
        ports:
        - containerPort: 3000
EOL

cat <<EOL > k8s/backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: quiz-backend
spec:
  selector:
    app: quiz-backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
EOL

cat <<EOL > k8s/frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quiz-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: quiz-frontend
  template:
    metadata:
      labels:
        app: quiz-frontend
    spec:
      containers:
      - name: quiz-frontend
        image: quiz-frontend:latest
        ports:
        - containerPort: 80
EOL

cat <<EOL > k8s/frontend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: quiz-frontend
spec:
  selector:
    app: quiz-frontend
  ports:
    - protocol: TCP
      port: 80
EOL

# Create GitHub Actions workflow for CI/CD
echo "Creating GitHub Actions CI/CD workflow..."
mkdir -p .github/workflows
cat <<EOL > .github/workflows/docker-build-push.yml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: \${{ secrets.DOCKER_USERNAME }}
          password: \${{ secrets.DOCKER_PASSWORD }}

      - name: Build and Push Docker Image for Backend
        uses: docker/build-push-action@v4
        with:
          context: ./backend
          file: ./backend/Dockerfile
          push: true
          tags: yourdockerhub/quiz-backend:latest

      - name: Build and Push Docker Image for Frontend
        uses: docker/build-push-action@v4
        with:
          context: ./frontend
          file: ./frontend/Dockerfile
          push: true
          tags: yourdockerhub/quiz-frontend:latest
EOL

# Final success message
echo "Setup complete! You can now run the app locally, build the Docker images, or use Kubernetes."
