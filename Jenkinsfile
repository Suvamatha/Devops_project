pipeline {
    agent any
    environment {
        dockerImage = 'suvam1/devops-project'
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
        // stage('Quality Gate Check') {
        //     steps {
        //         timeout(time: 5, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
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
        stage('Push Image') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub-credentials', url: ''){
                    sh '''
                    docker push $dockerImages:$BUILD_NUMBER
                    '''
                }
            }
        }
    }

    // post {
    //     always {
    //         sh 'docker system prune -f'
    //         mail to: 'shresthasuvam27@gmail.com',
    //              subject: "Jenkins Job '${JOB_NAME}' (${BUILD_NUMBER}) Status",
    //              body: "Check the build details here: ${BUILD_URL}"
    //     }
    //     success {
    //         mail to: 'shresthasuvam27@gmail.com',
    //              subject: 'BUILD SUCCESS NOTIFICATION',
    //              body: "Hi Team,\n\nBuild #${BUILD_NUMBER} passed all quality checks and was successfully processed.\nDocker Image: ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}\nFor more details, visit: ${BUILD_URL}\n\nRegards,\nDevOps Team"
    //     }
    //     failure {
    //         mail to: 'shresthasuvam27@gmail.com',
    //              subject: 'BUILD FAILED NOTIFICATION',
    //              body: "Hi Team,\n\nBuild #${BUILD_NUMBER} failed during the '${currentBuild.result}' stage.\nPlease review the logs for more information: ${BUILD_URL}\n\nRegards,\nDevOps Team"
    //     }
    // }
}