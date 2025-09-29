# Use the official Node.js 16 image as the base image
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json for dependency installation
COPY package*.json ./

# Install the application dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose a 8080 port
EXPOSE 8080

ENV DOCKER_TLS_CERTDIR=/certs

VOLUME /certs/ca
VOLUME /certs/client
VOLUME /var/jenkins_home

# USER root 

# Define the command to run the application
CMD ["npm", "start", "node", "app.js"]

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.04.0-ce.tgz \
  && tar xzvf docker-17.04.0-ce.tgz \
  && mv docker/docker /usr/local/bin \
  && rm -r docker docker-17.04.0-ce.tgz
