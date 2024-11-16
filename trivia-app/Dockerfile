FROM golang:1.20

WORKDIR /app
COPY backend/main.go .
COPY backend/index.html .

RUN go build -o trivia-app main.go

EXPOSE 8080
CMD ["./trivia-app"]
