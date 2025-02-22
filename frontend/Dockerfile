FROM node:16

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy the rest of the application code
COPY . .

EXPOSE 3000

# Start the Vue development server
CMD ["npm", "run", "serve"]
