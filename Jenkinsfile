pipeline {
    agent {
        dockerfile true
        /*docker {
            image 'node:16'  // Use Node 16 Docker image as build agent
            args '-u root:root --privileged -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080'   // Run as root to avoid permission issues
        //    args '--privileged'
        }*/
    }
    environment {
        REGISTRY = "rulyw"  // Replace with your Docker registry
        IMAGE_NAME = "21784408_project2"           // Replace with your app name
        DOCKER_CREDENTIALS = credentials('7483548c-0642-48cf-b17d-920161f911b9')  // Docker credentials in Jenkins
    }
    tools {
        'org.jenkinsci.plugins.docker.commons.tools.DockerTool' 'mydocker'
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
                /*script {
                    def response = httpRequest(
                        url: 'http://localhost:8080',
                        customHeaders: [[name: 'Authorization', value: 'Bearer YOUR_TOKEN']]
                    )
                    println "Status: ${response.status}"
                    println "Content: ${response.content}"
                }*/
            }
        }
        /*stage('Make HTTP Request') {
            steps {
                script {
                    def response = httpRequest 'http://localhost:8080'
                    println "Status: ${response.status}"
                    println "Content: ${response.content}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER .'
        
            }
        }*/
        

        stage('Build Docker Image') {
            steps {
                script {
                    // Use the Docker tool in your pipeline by calling the Docker CLI
                    // The tool name 'mydocker' will be automatically used by Jenkins to find the Docker binary

                    // Example: build the Docker image using 'docker' command
                    sh '''#!/bin/bash
                    ${tool 'mydocker'} build -t mydocker-image .
                    '''
                }
                /*echo "$DOCKER_HOST"
                sh '''
                  docker ps -a
                '''*/
            }
        }


        stage('Push Docker Image') {
            steps {
                // This step should not normally be used in your script. Consult the inline help for details.
                echo 'aa'
            //    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            //        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $REGISTRY'
            //    }
            //    sh 'docker push $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER'
            //}
                // Gunakan kredensial yang disimpan di Jenkins untuk login ke Docker Registry
                //withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                //    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $REGISTRY'
                //}
                // Push image ke Docker Registry
                //sh 'docker push $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER'
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
