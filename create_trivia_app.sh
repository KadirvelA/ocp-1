#!/bin/bash

# Define the base directory
BASE_DIR="trivia-app"

# Create the directory structure
mkdir -p $BASE_DIR/{backend,helm-chart/trivia-app/templates,.github/workflows}

# Create files with content

# backend/main.go
cat << 'EOF' > $BASE_DIR/backend/main.go
package main

import (
	"encoding/json"
		"math/rand"
			"net/http"
				"time"
			)

			type Question struct {
				Question string   `json:"question"`
					Options  []string `json:"options"`
						Answer   int      `json:"answer"` // Index of the correct answer
					}

					var questions = []Question{
						{"What is the capital of France?", []string{"Paris", "Berlin", "Madrid", "Rome"}, 0},
								{"What is 5 + 3?", []string{"5", "8", "12", "15"}, 1},
										{"Who wrote '1984'?", []string{"George Orwell", "Mark Twain", "J.K. Rowling", "Ernest Hemingway"}, 0},
										}

										func main() {
											rand.Seed(time.Now().UnixNano())

												http.HandleFunc("/api/questions", func(w http.ResponseWriter, r *http.Request) {
														w.Header().Set("Content-Type", "application/json")
																json.NewEncoder(w).Encode(questions)
																	})

																		http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
																				http.ServeFile(w, r, "./index.html")
																					})

																						http.ListenAndServe(":8080", nil)
																					}
																					EOF

																					# backend/index.html
																					cat << 'EOF' > $BASE_DIR/backend/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trivia Quest</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }
    button { padding: 10px 20px; margin: 10px; font-size: 18px; cursor: pointer; }
  </style>
</head>
<body>
  <h1>Welcome to Trivia Quest!</h1>
  <div id="app">
    <button onclick="startQuiz()">Start Quiz</button>
  </div>
  <script>
    let currentQuestion = 0;
    let score = 0;
    let questions = [];

    function startQuiz() {
      fetch('/api/questions')
        .then(res => res.json())
        .then(data => {
          questions = data;
          showQuestion();
        });
    }

    function showQuestion() {
      if (currentQuestion >= questions.length) {
        document.getElementById('app').innerHTML = `<h2>Your Score: ${score}/${questions.length}</h2>
          <button onclick="startQuiz()">Play Again</button>`;
        return;
      }

      const q = questions[currentQuestion];
      document.getElementById('app').innerHTML = `
        <h2>${q.question}</h2>
        ${q.options.map((opt, i) => `<button onclick="checkAnswer(${i})">${opt}</button>`).join('')}
      `;
    }

    function checkAnswer(selected) {
      if (questions[currentQuestion].answer === selected) score++;
      currentQuestion++;
      showQuestion();
    }
  </script>
</body>
</html>
EOF

# helm-chart/Chart.yaml
cat << 'EOF' > $BASE_DIR/helm-chart/trivia-app/Chart.yaml
apiVersion: v2
name: trivia-app
description: A simple trivia app
type: application
version: 0.1.0
appVersion: 1.0.0
EOF

# helm-chart/values.yaml
cat << 'EOF' > $BASE_DIR/helm-chart/trivia-app/values.yaml
image:
  repository: your-dockerhub-user/trivia-app
  tag: latest
appname: trivia-app
replicas: 2
EOF

# helm-chart/templates/deployment.yaml
cat << 'EOF' > $BASE_DIR/helm-chart/trivia-app/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Values.appname }}"
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: "{{ .Values.appname }}"
  template:
    metadata:
      labels:
        app: "{{ .Values.appname }}"
    spec:
      containers:
        - name: "{{ .Values.appname }}"
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 8080
EOF

# helm-chart/templates/service.yaml
cat << 'EOF' > $BASE_DIR/helm-chart/trivia-app/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: "{{ .Values.appname }}"
spec:
  selector:
    app: "{{ .Values.appname }}"
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOF

# helm-chart/templates/ingress.yaml
cat << 'EOF' > $BASE_DIR/helm-chart/trivia-app/templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: "{{ .Values.appname }}"
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: trivia-demo.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: "{{ .Values.appname }}"
                port:
                  number: 80
EOF

# .github/workflows/docker-build.yml
cat << 'EOF' > $BASE_DIR/.github/workflows/docker-build.yml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Log in to Docker Hub
      uses: docker/login-action@v2
      with:
        username: \${{ secrets.DOCKER_USERNAME }}
        password: \${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        file: ./Dockerfile
        push: true
        tags: your-dockerhub-user/trivia-app:latest
EOF

# .dockerignore
cat << 'EOF' > $BASE_DIR/.dockerignore
*.log
*.tmp
EOF

# Dockerfile
cat << 'EOF' > $BASE_DIR/Dockerfile
FROM golang:1.20

WORKDIR /app
COPY backend/main.go .
COPY backend/index.html .

RUN go build -o trivia-app main.go

EXPOSE 8080
CMD ["./trivia-app"]
EOF

# README.md
cat << 'EOF' > $BASE_DIR/README.md
# Trivia App

A simple trivia application with a Go backend and an interactive front-end, deployable via Docker and Helm.

## GitHub Actions Workflow
The included workflow automates Docker builds and pushes the image to Docker Hub.

## Helm Chart
Easily deploy the app to Kubernetes using the provided Helm chart.
EOF

# Notify user
echo "Project created at $BASE_DIR"

