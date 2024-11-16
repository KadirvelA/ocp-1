#!/bin/bash

# Root project directory
ROOT_DIR="trivia-app"

# Backend and Frontend directories
BACKEND_DIR="$ROOT_DIR/trivia-backend"
FRONTEND_DIR="$ROOT_DIR/trivia-frontend"
K8S_DIR="$ROOT_DIR/k8s"

# GitHub Actions directory
GITHUB_ACTIONS_DIR="$ROOT_DIR/.github/workflows"

# Create the root project directory
mkdir -p $ROOT_DIR

# Backend setup
echo "Setting up Backend..."

# Create the trivia-backend directory
mkdir -p $BACKEND_DIR

# Initialize npm in the backend directory
cd $BACKEND_DIR
npm init -y
npm install express axios

# Create the backend API file
cat <<EOL > $BACKEND_DIR/index.js
const express = require('express');
const axios = require('axios');
const app = express();
const port = 3001;

app.get('/api/questions', async (req, res) => {
  try {
    const response = await axios.get('https://opentdb.com/api.php?amount=5&type=multiple');
    res.json(response.data.results);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch trivia questions' });
  }
});

app.listen(port, () => {
  console.log(\`Backend listening at http://localhost:\${port}\`);
});
EOL

# Create Dockerfile for the backend
cat <<EOL > $BACKEND_DIR/Dockerfile
# Dockerfile for Node.js Backend
FROM node:16

WORKDIR /app

# Copy the application files
COPY . .

# Install dependencies
RUN npm install

EXPOSE 3001

CMD ["node", "index.js"]
EOL

# Frontend setup
echo "Setting up Frontend..."

# Create the trivia-frontend directory
cd $ROOT_DIR
npx create-react-app trivia-frontend
cd $FRONTEND_DIR
npm install axios

# Create the Trivia component
cat <<EOL > $FRONTEND_DIR/src/Trivia.js
import React, { useState, useEffect } from 'react';
import axios from 'axios';

const Trivia = () => {
  const [questions, setQuestions] = useState([]);
  const [currentQuestion, setCurrentQuestion] = useState(0);

  useEffect(() => {
    axios.get('http://localhost:3001/api/questions')
      .then(response => {
        setQuestions(response.data);
      })
      .catch(error => console.error('Error fetching trivia questions:', error));
  }, []);

  if (questions.length === 0) {
    return <div>Loading questions...</div>;
  }

  const question = questions[currentQuestion];

  return (
    <div>
      <h1>{question.question}</h1>
      <ul>
        {question.incorrect_answers.concat(question.correct_answer).map((answer, index) => (
          <li key={index}>{answer}</li>
        ))}
      </ul>
    </div>
  );
};

export default Trivia;
EOL

# Create Dockerfile for the frontend
cat <<EOL > $FRONTEND_DIR/Dockerfile
# Dockerfile for React Frontend
FROM node:16

WORKDIR /app

# Copy the application files
COPY . .

# Install dependencies
RUN npm install

# Build the React app
RUN npm run build

# Serve the build with a static file server
RUN npm install -g serve
CMD ["serve", "-s", "build", "-l", "5000"]
EOL

# GitHub Actions setup
echo "Setting up GitHub Actions..."

# Create .github/workflows directory
mkdir -p $GITHUB_ACTIONS_DIR

# Create GitHub Actions workflow for CI
cat <<EOL > $GITHUB_ACTIONS_DIR/ci.yml
name: CI for Trivia App

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: \${{ secrets.DOCKER_USERNAME }}
          password: \${{ secrets.DOCKER_PASSWORD }}

      - name: Build and Push Backend Docker Image
        uses: docker/build-push-action@v2
        with:
          context: ./trivia-backend
          file: ./trivia-backend/Dockerfile
          push: true
          tags: yourdockerhubusername/trivia-backend:latest

      - name: Build and Push Frontend Docker Image
        uses: docker/build-push-action@v2
        with:
          context: ./trivia-frontend
          file: ./trivia-frontend/Dockerfile
          push: true
          tags: yourdockerhubusername/trivia-frontend:latest
EOL

# Kubernetes setup
echo "Setting up Kubernetes Manifests..."

# Create the k8s directory
mkdir -p $K8S_DIR

# Create Kubernetes manifest files

# Backend Deployment
cat <<EOL > $K8S_DIR/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trivia-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: trivia-backend
  template:
    metadata:
      labels:
        app: trivia-backend
    spec:
      containers:
      - name: trivia-backend
        image: yourdockerhubusername/trivia-backend:latest
        ports:
        - containerPort: 3001
EOL

# Frontend Deployment
cat <<EOL > $K8S_DIR/frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trivia-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: trivia-frontend
  template:
    metadata:
      labels:
        app: trivia-frontend
    spec:
      containers:
      - name: trivia-frontend
        image: yourdockerhubusername/trivia-frontend:latest
        ports:
        - containerPort: 5000
EOL

# Backend Service
cat <<EOL > $K8S_DIR/backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: trivia-backend-service
spec:
  selector:
    app: trivia-backend
  ports:
    - protocol: TCP
      port: 3001
      targetPort: 3001
  type: ClusterIP
EOL

# Frontend Service
cat <<EOL > $K8S_DIR/frontend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: trivia-frontend-service
spec:
  selector:
    app: trivia-frontend
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
  type: LoadBalancer
EOL

echo "Setup Complete! You can now build, deploy and manage the Trivia App."
