pipeline {
    agent any // Reverted to 'any' to avoid 'docker-node' label issue
    
    environment {
        DOCKER_IMAGE = 'my-app-image'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        scannerHome = tool 'sonar7.0' // Ensure 'sonar7.0' is configured in Jenkins
    }
    
    stages {
        stage('Git Checkout') {
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
        
        stage('Run Tests') {
            steps {
                script {
                    try {
                        sh 'composer install' // Install PHP dependencies
                        sh 'vendor/bin/phpunit --coverage-clover coverage.xml' // Generate PHP coverage report
                        sh 'npm install && npm run test -- --coverage' // Generate JS coverage report
                    } catch (Exception e) {
                        error "Tests failed: ${e.message}"
                    }
                }
            }
        }
        
        stage('Code Quality Check') {
            steps {
                withSonarQubeEnv(credentialsId: 'sonarqube-token', installationName: 'MySonarQube') {
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
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
        
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true // Fail pipeline if quality gate fails
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    } catch (Exception e) {
                        error "Docker build failed: ${e.message}"
                    }
                }
            }
        }
        
        stage('Run Docker Container') {
            steps {
                script {
                    try {
                        sh 'docker stop my-app-container || true'
                        sh 'docker rm my-app-container || true'
                        sh "docker run -d --name my-app-container -p 8081:80 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    } catch (Exception e) {
                        error "Docker container run failed: ${e.message}"
                    }
                }
            }
        }
        
        stage('Trivy Scan') {
            steps {
                script {
                    try {
                        sh "trivy image --format json --output trivy-report.json ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        sh "trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                    } catch (Exception e) {
                        error "Trivy scan failed: ${e.message}"
                    }
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    try {
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} suvam1/${DOCKER_IMAGE}:${DOCKER_TAG}"
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} suvam1/${DOCKER_IMAGE}:latest"
                        withDockerRegistry(credentialsId: 'Dockerhub-cred', url: 'https://index.docker.io/v1/') {
                            sh "docker push suvam1/${DOCKER_IMAGE}:${DOCKER_TAG}"
                            sh "docker push suvam1/${DOCKER_IMAGE}:latest"
                        }
                    } catch (Exception e) {
                        error "Docker push failed: ${e.message}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker system prune -f' // Cleanup unused Docker images
            mail to: 'shresthasuvam27@gmail.com',
                 subject: "Job '${JOB_NAME}' (${BUILD_NUMBER}) status",
                 body: "Please go to ${BUILD_URL} and verify the build"
        }
        success {
            mail to: 'shresthasuvam27@gmail.com',
                 subject: 'BUILD SUCCESS NOTIFICATION',
                 body: """Hi Team,
Build #${BUILD_NUMBER} passed all quality checks and was deployed.
Docker Image: suvam1/${DOCKER_IMAGE}:${DOCKER_TAG}
Details: ${BUILD_URL}
Regards,
DevOps Team"""
        }
        failure {
            mail to: 'shresthasuvam27@gmail.com', // Unified email address
                 subject: 'BUILD FAILED NOTIFICATION',
                 body: """Hi Team,
Build #${BUILD_NUMBER} failed during:
${currentBuild.result} stage
Check logs: ${BUILD_URL}
Regards,
DevOps Team"""
        }
    }
}