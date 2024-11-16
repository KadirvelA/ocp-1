#!/bin/bash

# Set variables
REGISTRY="akadirvel1/trivia-frontend"
APP_DIR="trivia-app"

# Clean up old directories
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/backend" "$APP_DIR/frontend" "$APP_DIR/k8s"

# Create backend files
cat <<EOF > "$APP_DIR/backend/app.py"
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({"message": "Welcome to the Flask Backend!"})

@app.route("/health")
def health():
    return jsonify({"status": "UP"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

cat <<EOF > "$APP_DIR/backend/requirements.txt"
Flask==2.1.2
EOF

cat <<EOF > "$APP_DIR/backend/Dockerfile"
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

EXPOSE 5000
CMD ["python", "app.py"]
EOF

# Create frontend files
cat <<EOF > "$APP_DIR/frontend/index.html"
<!DOCTYPE html>
<html>
<head>
    <title>Trivia App Frontend</title>
</head>
<body>
    <h1>Welcome to the Trivia App Frontend!</h1>
</body>
</html>
EOF

cat <<EOF > "$APP_DIR/frontend/Dockerfile"
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create Kubernetes manifests
cat <<EOF > "$APP_DIR/k8s/backend-deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: $REGISTRY-backend:latest
        ports:
        - containerPort: 5000
EOF

cat <<EOF > "$APP_DIR/k8s/backend-service.yaml"
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  type: LoadBalancer
  selector:
    app: backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
EOF

cat <<EOF > "$APP_DIR/k8s/frontend-deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: $REGISTRY-frontend:latest
        ports:
        - containerPort: 80
EOF

cat <<EOF > "$APP_DIR/k8s/frontend-service.yaml"
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF

# Build and push Docker images
docker build -t $REGISTRY-backend:latest "$APP_DIR/backend"
docker build -t $REGISTRY-frontend:latest "$APP_DIR/frontend"

docker push $REGISTRY-backend:latest
docker push $REGISTRY-frontend:latest

# Deploy Kubernetes manifests
kubectl apply -f "$APP_DIR/k8s/"

echo "Setup complete! Access the frontend and backend using their LoadBalancer IPs."
