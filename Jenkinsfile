pipeline {
  agent {
    // Build inside a Node 16 container (requirement 3.1.b.i)
    docker {
      image 'node:16'
      // Re-use DinD as remote Docker daemon via DOCKER_HOST inherited from Jenkins service
      args '-u root:root -v $WORKSPACE:/workspace -w /workspace'
    }
  }

  environment {
    // Docker registry settings (set these in Jenkins > Manage Credentials)
    DOCKER_REGISTRY_URL = 'https://index.docker.io/v1/'           // or your private registry
    DOCKER_IMAGE_NAME   = 'yourdockeruser/eb-express-sample'      // change to your image name
    DOCKER_IMAGE_TAG    = "build-${env.BUILD_NUMBER}"

    // Credentials IDs you will create in Jenkins:
    DOCKER_REGISTRY_CRED = credentials('docker-registry-cred')    // username/password
    SNYK_TOKEN_CRED      = credentials('snyk-token')               // secret text

    // tell docker cli where to talk (inherited in jenkins service) — kept for clarity in logs
    DOCKER_HOST = 'tcp://dind:2375'
  }

  options {
    timestamps()
    ansiColor('xterm')
    buildDiscarder(logRotator(numToKeepStr: '20', daysToKeepStr: '14')) // retention (Task 4.2.a)
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
        sh 'npm test --silent || (echo "Tests failed" && exit 1)'
      }
      post {
        always {
          // If you configure jest-junit, you can publish JUnit; else just archive logs
          archiveArtifacts artifacts: 'npm-debug.log, **/junit*.xml', allowEmptyArchive: true
        }
      }
    }

    stage('Security scan (Snyk)') {
      steps {
        sh '''
          npm install -g snyk
          snyk auth ${SNYK_TOKEN_CRED}
          # Scan manifest; fail build on High/Critical
          snyk test --severity-threshold=high || (echo "Snyk high/critical found"; exit 1)
        '''
      }
    }

    stage('Build Docker image') {
      steps {
        sh '''
          echo "${DOCKER_REGISTRY_CRED_PSW}" | docker login -u "${DOCKER_REGISTRY_CRED_USR}" --password-stdin
          docker version
          docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .
          docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest
        '''
      }
    }

    stage('Push image') {
      steps {
        sh '''
          docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
          docker push ${DOCKER_IMAGE_NAME}:latest
        '''
      }
    }

    // Optional: Deploy stage could go here (e.g., docker compose up on a target host)
  }

  post {
    success {
      echo "Build #${env.BUILD_NUMBER} succeeded"
    }
    failure {
      echo "Build #${env.BUILD_NUMBER} failed"
    }
    always {
      // Archive Dockerfile and Snyk outputs if any
      archiveArtifacts artifacts: 'Dockerfile, snyk*.json, **/*.log', allowEmptyArchive: true
    }
  }
}
// pipeline {
//     agent {
//         dockerfile true
//         /*docker {
//             image 'node:16'  // Use Node 16 Docker image as build agent
//             args '-u root:root --privileged -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080'   // Run as root to avoid permission issues
//         //    args '--privileged'
//         }*/
//     }
//     environment {
//         REGISTRY = "rulyw"  // Replace with your Docker registry
//         IMAGE_NAME = "21784408_project2"           // Replace with your app name
//         DOCKER_CREDENTIALS = credentials('7483548c-0642-48cf-b17d-920161f911b9')  // Docker credentials in Jenkins
//     }
//     tools {
//         'org.jenkinsci.plugins.docker.commons.tools.DockerTool' 'mydocker'
//     }
//     stages {
//         stage('Checkout') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/rulyw/aws-elastic-beanstalk-express-js-sample.git'  // Update repo URL
//             }
//         }
//         stage('Install Dependencies') {
//             steps {
//                 sh 'npm install --save'
//             }
//         }

//         stage('Run Tests') {
//             steps {
//                 sh 'npm run'
//                 /*script {
//                     def response = httpRequest(
//                         url: 'http://localhost:8080',
//                         customHeaders: [[name: 'Authorization', value: 'Bearer YOUR_TOKEN']]
//                     )
//                     println "Status: ${response.status}"
//                     println "Content: ${response.content}"
//                 }*/
//             }
//         }
//         /*stage('Make HTTP Request') {
//             steps {
//                 script {
//                     def response = httpRequest 'http://localhost:8080'
//                     println "Status: ${response.status}"
//                     println "Content: ${response.content}"
//                 }
//             }
//         }
//         stage('Build Docker Image') {
//             steps {
//                 sh 'docker build -t $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER .'
//             }
//         }*/
        

//         stage('Build Docker Image') {
//             steps {
//                 script{
//                     docker.build('myapp')
//                 }
//                /* script {
//                     // Use the Docker tool in your pipeline by calling the Docker CLI
//                     def docker = tool name: 'mydocker' // Get the path to Docker tool
//                     echo "Docker path: ${docker}"  // Optionally print the path for debugging
                    
//                     // Use the resolved path of Docker in the shell commands
//                     sh """
//                         $docker build -t mydocker-image .
//                     """
//                 }
//                 echo "$DOCKER_HOST"
//                 sh '''
//                   docker ps -a
//                 '''*/
//             }
//         }


//         stage('Push Docker Image') {
//             steps {
//                 // This step should not normally be used in your script. Consult the inline help for details.
//                 echo 'aa'
//             //    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
//             //        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $REGISTRY'
//             //    }
//             //    sh 'docker push $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER'
//             //}
//                 // Gunakan kredensial yang disimpan di Jenkins untuk login ke Docker Registry
//                 //withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
//                 //    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $REGISTRY'
//                 //}
//                 // Push image ke Docker Registry
//                 //sh 'docker push $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER'
//             }
//         }
//     }

//     post {
//         success {
//             echo 'Pipeline succeeded!'
//         }
//         failure {
//             echo 'Pipeline failed!'
//         }
//     }
// }
// // 
