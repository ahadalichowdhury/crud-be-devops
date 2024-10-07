# Stage 1: Build
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Accept build arguments for environment variables
ARG MONGODB_URI

# Set environment variables inside the container
ENV MONGODB_URI=$MONGODB_URI

# Expose port (change if necessary)
EXPOSE 5000

# Command to run the application
CMD ["node", "index.js"]