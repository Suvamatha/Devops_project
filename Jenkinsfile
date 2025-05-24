pipeline {
    agent { label 'docker-node' }

    environment {
        DOCKER_IMAGE = 'my-app-image'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        scannerHome = tool 'sonar7.0'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Suvamatha/Devops_project.git'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'composer install'
                sh 'vendor/bin/phpunit --coverage-clover coverage.xml'
                sh 'npm install && npm run test -- --coverage'
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
                    waitForQualityGate abortPipeline: true
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
                    sh 'docker stop my-app-container || true'
                    sh 'docker rm my-app-container || true'
                    sh "docker run -d --name my-app-container -p 8081:80 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Trivy Scan') {
            steps {
                script {
                    sh "trivy image --format json --output trivy-report.json ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} suvam1/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} suvam1/${DOCKER_IMAGE}:latest"
                    withDockerRegistry(credentialsId: 'Dockerhub-cred', url: 'https://index.docker.io/v1/') {
                        sh "docker push suvam1/${DOCKER_IMAGE}:${DOCKER_TAG}"
                        sh "docker push suvam1/${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker system prune -f' // Cleanup unused images
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
            mail to: 'shresthasuvam27@gmail.com',
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