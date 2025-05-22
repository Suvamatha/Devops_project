pipeline {
    agent any

    environment {
        IMAGE_NAME = 'photogenic-web'
        TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Suvamatha/Devops_project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${TAG} ."
                }
            }
        }

        stage('Run Container') {
            steps {
                script {
                    sh """
                    docker rm -f ${IMAGE_NAME}_container || true
                    docker run -d --name ${IMAGE_NAME}_container -p 8080:80 ${IMAGE_NAME}:${TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up any previously running container...'
            sh "docker rm -f ${IMAGE_NAME}_container || true"
        }
    }
}
