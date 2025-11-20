FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all project files
COPY . .

# Build Next.js app
RUN npm run build

# Expose port 3000 (mapped to 1339 in docker-compose)
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
