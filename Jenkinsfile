pipeline {
    agent none 
    
    // Environment variables for Docker build and push
    environment {
        // !!! REPLACE WITH YOUR DOCKER HUB USERNAME !!!
        DOCKER_USER = 'rulyw' 
        // Generates a unique image tag based on the Jenkins Build ID
        DOCKER_IMAGE = "${DOCKER_USER}/testass2:${BUILD_ID}"
        DOCKERFILE_PATH = 'Dockerfile.deploy' // Use the one provided in the sample repo
        
        // Define the tool name configured in Jenkins Global Tool Configuration
        OWASP_DC_TOOL = 'OWASP-DC-CLI'
    }

    stages {
        stage('Setup Agent & Java') {
            // This stage is necessary to run commands that modify the base container
            // and install Java, which is required by Dependency-Check.
            agent {
                docker {
                    image 'node:16'
                    args '-u root' // Run as root to allow package installation
                }
            }
            steps {
                echo 'Setting up Java and fixing EOL Debian repositories...'
                
                // FIX: Replace old EOL deb.debian.org sources with archive.debian.org
                sh 'sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list'
                // Remove the security repository lines, which are often problematic
                sh 'sed -i "/security/d" /etc/apt/sources.list'

                // Update package lists and install the JDK (Java Development Kit)
                sh 'apt-get update && apt-get install -y default-jdk' 
            }
        }

        stage('Initialize & Unit Tests') {
            // Re-run on the same configured agent
            agent {
                docker {
                    image 'node:16-slim'
                    args '-u root'
                }
            }
            steps {
                echo 'Installing core Node.js dependencies...'
                sh 'npm install --save'

                echo 'Running unit tests...'
                sh 'npm test'
            }
        }

        stage('Dependency Scan (Security Integration)') {
            // Use the established agent
            agent {
                docker {
                    image 'node:16-slim'
                    args '-u root'
                }
            }
            steps {
                echo 'Running OWASP Dependency-Check using Jenkins Plugin...'
                
                // 1. Invoke Dependency-Check CLI via the plugin
                dependencyCheck(
                    scanPath: './', 
                    odcInstallation: env.OWASP_DC_TOOL, 
                    // Tell the CLI to output XML format (required by the publisher)
                    additionalArguments: '''--format XML --project='AWS-Express-App' --suppressPlainTextReport'''
                )
                
                // 2. Publish results and configure failure thresholds
                dependencyCheckPublisher(
                    pattern: '**/dependency-check-report.xml',
                    // Fails the build if 1 or more HIGH/CRITICAL vulnerabilities are found
                    failedTotalHigh: 1,      
                    failedTotalCritical: 1   
                )
            }
        }

        stage('Containerization') {
            agent {
                // Use a standard Docker agent to interact with the DinD service
                docker {
                    image 'node:16-slim' 
                    args '-u root'
                }
            }
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE}"
                // The DOCKER_HOST env var (set in docker-compose.yaml) directs this command to DinD
                //sh "docker build -t ${DOCKER_IMAGE} -f ${DOCKERFILE_PATH} ."
                sh "docker build -t ${DOCKER_IMAGE} -f ."
            }
        }

        //stage('Push to Registry') {
        //    when {
        //        // Only push if the previous stages (including security scan) were successful
        //        expression { return currentBuild.result == 'SUCCESS' }
        //    }
        //    agent {
        //        docker {
        //            image 'node:16' 
        //            args '-u root'
        //        }
        //    }
        //    steps {
        //        echo "Pushing Docker image: ${DOCKER_IMAGE}"
        //        // Use Jenkins Credentials ID (e.g., 'dockerhub-credentials-id')
        //        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
        //            sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
        //            sh "docker push ${DOCKER_IMAGE}"
        //        }
        //    }
        //}
    }
}
