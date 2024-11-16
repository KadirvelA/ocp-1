# Use a simple Nginx image for static content
FROM nginx:alpine

# Copy the frontend files to the appropriate directory
COPY trivia-app/trivia-frontend/index.html /usr/share/nginx/html/index.html

# Expose port 80 to serve the app
EXPOSE 80
