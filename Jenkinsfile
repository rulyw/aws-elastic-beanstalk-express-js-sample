version: '3.8'

services:
  # Docker-in-Docker (DinD) service
  dind:
    container_name: dind-assignment2
    image: docker:19.03.12-dind
    privileged: true
    environment:
      DOCKER_TLS_CERTDIR: "/certs"
    volumes:
      - docker-certs:/certs/client
      - docker-data:/var/lib/docker
    networks:
      - jenkins_network

  # Jenkins service
  jenkins:
    container_name: jenkins-assignment2
    image: jenkins/jenkins:lts
    environment:
      JENKINS_OPTS: "--prefix=/jenkins"
      JAVA_OPTS: "-Djenkins.install.runSetupWizard=false"
    ports:
      - "8080:8080"  # Jenkins will still use port 8080
      - "50000:50000"  # Agent communication port
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - dind
    networks:
      - jenkins_network

  # Node.js application service
  app:
    container_name: node-app
    build: .
    ports:
      - "3000:3000"  # Map port 3000 on host to port 3000 in the container
    depends_on:
      - jenkins
    networks:
      - jenkins_network

volumes:
  jenkins_home: {}
  docker-data: {}
  docker-certs: {}

networks:
  jenkins_network:
    driver: bridge
