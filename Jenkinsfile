// Use a declarative pipeline syntax
pipeline {
    // Define environment variables
    environment {
        // Define your Docker Hub username
        DOCKER_USER = 'rulyw' 
        DOCKER_IMAGE = "${DOCKER_USER}/testass2app:${BUILD_ID}"
        DOCKERFILE_PATH = 'Dockerfile.deploy' // Use the one provided in the sample repo
        // Dependency Check Settings
        DC_REPORT = 'dependency-check-report.xml'
    }

    // Set the build agent using the required Node.js version (i)
    agent {
        docker {
            // Using Node 16 slim for the core build agent
            image 'node:16'
            // We use root to avoid permission issues during npm install and installing Java/DC
            args '-u root' 
        }
    }

    stages {
        stage('Initialize & Dependencies (ii)') {
            steps {
                echo 'Installing core Node.js dependencies...'
                sh 'npm install --save'
            }
        }
        stage('Dependency Scan (OWASP Dependency-Check)') {
            steps {
                echo 'Setting up and running OWASP Dependency-Check...'
                
                // --- FIX: Change sources.list to point to the Debian archive ---
                sh 'sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list'
                sh 'sed -i "/security/d" /etc/apt/sources.list'
                // -----------------------------------------------------------------

                // Install Java/JDK (required by Dependency-Check CLI)
                sh 'apt-get update && apt-get install -y default-jdk' 
                
                // Install Dependency-Check CLI (via NPM)
                sh 'npm install -g dependency-check'

                // Run the scan...
                sh "dependency-check --scan=./ --project='AWS-Express-App' --format=XML --out=./ --failOnCVSS=7.0"
                
                archiveArtifacts artifacts: "${DC_REPORT}", onlyIfSuccessful: true
            }
        }

        stage('Build Docker Image (ii)') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE}"
                // Build the Docker image using the DinD daemon (via DOCKER_HOST environment variable)
                sh "docker build -t ${DOCKER_IMAGE} -f ${DOCKERFILE_PATH} ."
            }
        }

        //stage('Push to Registry (ii)') {
        //    // Assumes Docker Hub credentials are set up in Jenkins as 'dockerhub-credentials-id'
        //    when {
        //        expression { return currentBuild.result == 'SUCCESS' }
        //    }
        //    steps {
        //        echo "Pushing Docker image: ${DOCKER_IMAGE}"
        //        // Securely retrieve credentials
        //        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
        //            sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
        //            sh "docker push ${DOCKER_IMAGE}"
        //        }
        //    }
        //}
    }
}
