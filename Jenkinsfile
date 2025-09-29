pipeline {
    agent {
        docker {
            image 'node:16'  // Use Node 16 Docker image as build agent
            args '-u root'   // Run as root to avoid permission issues
            args '--privileged'
        }
    }
    environment {
        REGISTRY = "rulyw"  // Replace with your Docker registry
        IMAGE_NAME = "21784408_project2"           // Replace with your app name
        DOCKER_CREDENTIALS = credentials('7483548c-0642-48cf-b17d-920161f911b9')  // Docker credentials in Jenkins
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/rulyw/aws-elastic-beanstalk-express-js-sample.git'  // Update repo URL
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm run'
            }
        }

        //stage('Build Docker Image') {
        //    steps {
                //sh 'docker build -t $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER .'
        //        sh 'docker version'
        //    }
        //}

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $REGISTRY'
                }
                sh 'docker push $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER'
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
