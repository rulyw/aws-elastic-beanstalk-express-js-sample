pipeline {
    agent none 
    
    environment {
        // !!! REPLACE WITH YOUR DOCKER HUB USERNAME !!!
        DOCKER_USER = 'rulyw' 
        // Generates a unique image tag based on the Jenkins Build ID
        DOCKER_IMAGE = "${DOCKER_USER}/testass2:${BUILD_ID}"
        DOCKERFILE_PATH = 'Dockerfile.deploy' 
        
        // Define the tool name configured in Jenkins Global Tool Configuration
        OWASP_DC_TOOL = 'OWASP-DC-CLI'
    }

    stages {
        stage('Setup Agent & Java') {
            // This stage runs as root to install packages and fix EOL repos.
            agent {
                docker {
                    image 'node:16'
                    args '-u root'
                }
            }
            steps {
                echo 'Setting up Java and fixing EOL Debian repositories...'
                
                // FIX: Replace old EOL deb.debian.org sources with archive.debian.org
                sh 'sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list'
                // Remove the security repository lines
                sh 'sed -i "/security/d" /etc/apt/sources.list'

                // Update package lists and install the JDK (required by Dependency-Check)
                sh 'apt-get update && apt-get install -y default-jre' 
            }
        }

        stage('Initialize & Unit Tests') {
            agent {
                docker {
                    image 'node:16'
                    args '-u root'
                }
            }
            steps {
                echo 'Installing core Node.js dependencies...'
                sh 'npm install --save'

            }
        }

        stage('Dependency Scan (Security Integration)') {
            agent {
                docker {
                    image 'node:16'
                    args '-u root'
                }
            }
            steps {
                echo 'Running OWASP Dependency-Check using Jenkins Plugin...'
                
                // 1. SCANNER STEP: Invokes the CLI to run the analysis and generate the report.
                dependencyCheck(
                    // Parameter that was causing the error: it belongs here!
                    // scanPath: './', 
                    odcInstallation: env.OWASP_DC_TOOL, 
                    additionalArguments: '''--format XML --project='AWS-Express-App' --suppressPlainTextReport'''
                )
                
                // 2. PUBLISHER STEP: Reads the XML report, publishes results, and checks thresholds.
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
                docker {
                    image 'node:16-slim' 
                    args '-u root'
                }
            }
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE}"
                //sh "docker build -t ${DOCKER_IMAGE} -f ${DOCKERFILE_PATH} ."
                sh "docker build -t ${DOCKER_IMAGE} -f ."
            }
        }

        stage('Push to Registry') {
            when {
                // Only push if the previous stages (including security scan) were successful
                expression { return currentBuild.result == 'SUCCESS' }
            }
            agent {
                docker {
                    image 'node:16-slim' 
                    args '-u root'
                }
            }
            steps {
                echo "Pushing Docker image: ${DOCKER_IMAGE}"
                // NOTE: Replace 'dockerhub-credentials-id' with your actual Jenkins Credentials ID
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }
    }
}
