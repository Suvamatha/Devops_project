pipeline {
    agent any
    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Suvamatha/Devops_project.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t my-app-image .'
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                script {
                    sh 'docker run -d -p 8081:80 my-app-image'
                }
            }
        }
    }
}
