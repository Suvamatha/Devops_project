pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
              
                git 'https://github.com/Suvamatha/Devops_project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build('shapely-php-app')
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Stop old container if running
                    sh 'docker rm -f shapely-container || true'
                    // Run new one
                    sh 'docker run -d -p 8080:80 --name shapely-container shapely-php-app'
                }
            }
        }
    }
}
