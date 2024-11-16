# Use Node.js image
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json file to the container
COPY trivia-app/trivia-backend/package.json ./  

# Install dependencies
RUN npm install

# Copy the backend source code
COPY trivia-app/trivia-backend/index.js ./index.js

# Expose the port
EXPOSE 3000

# Command to start the backend
CMD ["node", "index.js"]
