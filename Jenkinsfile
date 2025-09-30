pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            args '-v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker'
        }
    }
    
    environment {
        // Docker registry settings (set these in Jenkins > Manage Credentials)
        DOCKER_REGISTRY_URL = 'https://index.docker.io/v1/'                     // or your private registry
        DOCKER_IMAGE_NAME     = 'rulyw/testass2'            // change to your image name
        DOCKER_IMAGE_TAG        = "build-${env.BUILD_NUMBER}"

        // Credentials IDs you will create in Jenkins:
        DOCKER_REGISTRY_CRED = credentials('0a521f0a-aba4-458b-98b0-8166149666c8')        // username/password
        // SNYK_TOKEN_CRED            = credentials('snyk-token')                             // secret text

        // tell docker cli where to talk (inherited in jenkins service) — kept for clarity in logs
        DOCKER_HOST = 'tcp://docker:2376'
    }


    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'node -v && npm -v'
                // Requirement says 'npm install --save' — typically you'd use `npm ci` for CI, but we follow brief:
                sh 'npm install --save'
                // Optional: produce a lockfile if missing for reproducibility
                sh 'if [ ! -f package-lock.json ]; then npm i --package-lock-only; fi'
                archiveArtifacts artifacts: 'package*.json', fingerprint: true
            }
        }

        stage('Unit tests') {
            steps {
                // If tests exist, run them; ensure non-zero exit fails the stage
                //sh 'npm test --silent || (echo "Tests failed" && exit 1)'
                // sh 'npm run'
                
                sh 'npm start & sleep 5'
                sh 'curl -f http://localhost:8080'
            }
        }


        stage('Build Docker image') {
            steps {
                sh '''
                  
                  docker build -t rulyw/assignment_21784408:step4 .
                  
                '''
            }
        }
        stage('Push image') {
            steps {
                sh '''
                echo $DOCKER_REGISTRY_CRED_PSW | docker login -u $DOCKER_REGISTRY_CRED_USR -p Assignment21784408
                docker push rulyw/assignment_21784408:step4
                '''
            }
        }

        stage('Security Scan') {
            steps {
                build job: 'OWASP-DC', 
                      parameters: [
                        string(name: 'APP_NAME', value: 'express-app'),
                        string(name: 'BRANCH', value: env.BRANCH_NAME)
                      ], 
                      wait: true
            }
        }
    }

    post {
        success {
            echo "Build #${env.BUILD_NUMBER} succeeded"
        }
        failure {
            echo "Build #${env.BUILD_NUMBER} failed"
        }
    }
}
