# Use the official Golang image
FROM golang:1.20

# Set working directory inside the container
WORKDIR /app

# Copy backend source code into the container
COPY backend/ .

# Build the Go application
RUN go build -o trivia-app main.go

# Expose the application port
EXPOSE 8080

# Command to run the application
CMD ["./trivia-app"]
