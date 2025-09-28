pipeline {
    agent {
        docker { 
            image 'node:16'  // Use Node.js 16 Docker image as the build agent
            args '-u root'   // Run as root (needed for installing dependencies and Docker tasks)
        }
    }

    environment {
        DOCKER_IMAGE = 'node:16' //'node-app'  // Docker image name for the Node.js app
        DOCKER_REGISTRY = 'docker.io' // Docker registry (change to your own if using a private registry)
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull the code from the Git repository
                checkout scm
            }
        }
        stage('Install Dependencies') {
            steps {
                // Install dependencies using npm
                script {
                    sh 'npm install --save'
                }
            }
        }
        //stage('Run Unit Tests') {
        //    steps {
        //        // Run unit tests (you can modify this based on your test framework, assuming `npm test`)
        //        script {
        //            sh 'npm test'
        //        }
        //    }
        //}
        stage('Build Docker Image') {
            steps {
                // Build Docker image for the Node.js app
                script {
                    //sh "docker build -t ${DOCKER_IMAGE}:${BUILD_ID} ."
                    //sh "docker ps -a"
                    docker.build('node-app:7')
                }
            }
        }
        //stage('Docker Security Scan') {
        //    steps {
        //        // Run a security scan on the Docker image (using Snyk CLI or any other scanner)
        //        script {
        //            sh "snyk test --docker ${DOCKER_IMAGE}:${BUILD_ID}"
        //        }
        //    }
        //}
        //stage('Push Docker Image') {
        //    when {
        //        branch 'main'  // Only push to Docker registry from the main branch
        //    }
        //    steps {
        //        script {
        //            sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${BUILD_ID}"
        //        }
        //    }
        //}
    }
    post {
        always {
            // Clean up Docker images after the build
            //sh 'docker system prune -f'
            echo 'always do this!'
        }
        success {
            // Notify success (optional)
            echo 'Build and Docker image pushed successfully!'
        }
        failure {
            // Handle failures (optional)
            echo 'Build failed. Please check the logs.'
        }
    }
}
