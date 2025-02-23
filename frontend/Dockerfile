# Use an official Node image as the base
FROM node:16-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy the rest of the app's source code
COPY . .

EXPOSE 3000

# Start the Vue development server
CMD ["npm", "run", "serve"]
