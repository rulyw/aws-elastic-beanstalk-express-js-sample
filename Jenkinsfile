// Use a declarative pipeline syntax
pipeline {
    // Define environment variables
    environment {
        // Specify Docker image name and tag
        DOCKER_IMAGE = "rulyw/testass2:${BUILD_ID}"
        // Set Snyk API Token from Jenkins Credentials
        // This credential MUST be a 'Secret Text' named 'SNYK_TOKEN'
        SNYK_TOKEN_ENV = credentials('3bee68f3-944a-4032-8998-600c5d1479f8')
        // Set the path to the Dockerfile
        DOCKERFILE_PATH = 'Dockerfile.deploy' // Use the one provided in the sample repo
    }

    // Set the build agent using the required Node.js version
    agent {
        docker {
            image 'node:16' // Node 16 Docker image as the build agent
            args '-u root' // Use root to avoid permission issues during npm install/snyk install
        }
    }

    // Define the stages of the CI/CD pipeline
    stages {
        stage('Initialize & Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                // Install dependencies
                sh 'npm install --save'
            }
        }

        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                // The sample app uses Mocha. Run the test script defined in package.json
                sh 'npm test'
            }
        }

        stage('Dependency Vulnerability Scan (Snyk)') {
            steps {
                echo 'Running Snyk vulnerability scan...'
                // Install Snyk CLI globally
                sh 'npm install -g snyk'
                // Authenticate Snyk using the token from Jenkins Credentials
                sh "snyk auth ${SNYK_TOKEN_ENV}"
                // Run a test, specifying the project type and setting the fail threshold.
                // Fail the build if any High or Critical vulnerability is found.
                // The '--severity-threshold=high' option enforces the failure requirement.
                sh 'snyk test --project-type=npm --severity-threshold=high'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE}"
                // Build the Docker image using the DinD daemon (via DOCKER_HOST)
                // Use the Dockerfile provided in the sample repo
                sh "docker build -t ${DOCKER_IMAGE} -f ${DOCKERFILE_PATH} ."
            }
        }

        stage('Push to Registry') {
            // This assumes you've configured Docker Hub credentials in Jenkins
            // (e.g., using 'Docker Registry' credentials type)
            // Replace 'dockerhub-credentials-id' with your actual Jenkins credential ID
            when {
                // Only execute if previous stages succeeded
                expression {
                    return currentBuild.result == 'SUCCESS' || currentBuild.result == null
                }
            }
            steps {
                echo "Pushing Docker image: ${DOCKER_IMAGE}"
                // Log in to Docker Hub using stored credentials
                withCredentials([usernamePassword(credentialsId: 'rulyw', passwordVariable: 'Assignment21784408', usernameVariable: 'rulyw')]) {
                    sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                    // Push the built image
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }
    }
}
