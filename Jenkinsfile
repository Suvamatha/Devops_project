pipeline {
    agent any
    
    environment {
        // Define your image name and tag
        DOCKER_IMAGE = 'my-app-image'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('git Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Suvamatha/Devops_project.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }
        
        stage('Run Docker Container') {
            steps {
                script {
                    // Stop and remove any existing container first to avoid conflicts
                    sh 'docker stop my-app-container || true'
                    sh 'docker rm my-app-container || true'
                    sh "docker run -d --name my-app-container -p 8081:80 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Trivy Scan for Docker Image') {
            steps {
                script {
                    // Fixed the trivy command syntax and variable reference
                    sh "trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} suvam1/${DOCKER_IMAGE}:${DOCKER_TAG}"
            
                    withDockerRegistry(
                        credentialsId: 'Dockerhub-cred', 
                        url: 'https://index.docker.io/v1/'
                    ) {
                        sh "docker push suvam1/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            mail to: 'shresthasuvam27@gmail.com',
            subject: "Job '${JOB_NAME}' (${BUILD_NUMBER}) status",
            body: "Please go to ${BUILD_URL} and verify the build"
        }

        success {
            mail bcc: '', 
                 body: """Hi Team,
Build #${BUILD_NUMBER} is successful, please go through the url
${BUILD_URL}
and verify the details.
Regards,
DevOps Team""", 
                 cc: '', 
                 from: '', 
                 replyTo: '', 
                 subject: 'BUILD SUCCESS NOTIFICATION', 
                 to: 'shresthasuvam27@gmail.com'
        }

        failure {
            mail bcc: '', 
                 body: """Hi Team,
Build #${BUILD_NUMBER} is unsuccessful, please go through the url
${BUILD_URL}
and verify the details.
Regards,
DevOps Team""", 
                 cc: '', 
                 from: '', 
                 replyTo: '', 
                 subject: 'BUILD FAILED NOTIFICATION', 
                 to: 'shresthasuvam27@gmail.com'
        }
    }
}