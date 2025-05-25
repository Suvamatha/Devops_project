pipeline {
    agent any
    environment {
        dockerImages = 'suvam1/jenkins-project'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_IMAGE_NAME = 'suvam1/jenkins-project'
        SONAR_SCANNER_HOME = tool 'sonar7.0'
    }
    stages {
        stage('Source Checkout') {
            steps {
                script {
                    try {
                        git branch: 'main', url: 'https://github.com/Suvamatha/Devops_project.git'
                    } catch (Exception e) {
                        error "Git checkout failed: ${e.message}"
                    }
                }
            }
        }
        stage('Run Unit and Integration Tests') {
            steps {
                script {
                    try {
                        sh 'composer install'
                        sh 'vendor/bin/phpunit --coverage-clover coverage.xml'
                        sh 'npm install && npm run test -- --coverage'
                    } catch (Exception e) {
                        error "Tests failed: ${e.message}"
                    }
                }
            }
        }
        stage('Code Quality Analysis (SonarQube)') {
            steps {
                withSonarQubeEnv(credentialsId: 'Sonarqube-auth-token', installationName: 'MySonarQube') {
                    sh """
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=devops-php-app \
                        -Dsonar.projectName='DevOps PHP Application' \
                        -Dsonar.sources=. \
                        -Dsonar.exclusions=node_modules/**,vendor/** \
                        -Dsonar.php.coverage.reportPaths=coverage.xml \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    """
                }
            }
        }
        stage('Quality Gate Check') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ."
                    } catch (Exception e) {
                        error "Docker image build failed: ${e.message}"
                    }
                }
            }
        }
        stage('Run Docker Container (Local)') {
            steps {
                script {
                    try {
                        sh 'docker stop my-app-container || true'
                        sh 'docker rm my-app-container || true'
                        sh "docker run -d --name my-app-container -p 8081:80 ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                    } catch (Exception e) {
                        error "Docker container run failed: ${e.message}"
                    }
                }
            }
        }
    }
    post {
        always {
            sh 'docker system prune -f'
        }
    }
}