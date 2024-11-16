# Use the official Golang image
FROM golang:1.20

# Set working directory inside the container
WORKDIR /app

# Copy Go modules files (if present)
COPY backend/go.mod backend/go.sum ./

# Download dependencies
RUN go mod tidy

# Copy backend source code into the container
COPY backend/ .

# Build the Go application
RUN go build -o trivia-app main.go

# Expose the application port
EXPOSE 8080

# Command to run the application
CMD ["./trivia-app"]
