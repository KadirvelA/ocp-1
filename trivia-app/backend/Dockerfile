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
