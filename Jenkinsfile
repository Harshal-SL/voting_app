pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-creds')
        DOCKER_HUB_REPO = 'harshalsl0209'

        BACKEND_IMAGE = "${DOCKER_HUB_REPO}/voting-app-backend"
        FRONTEND_IMAGE = "${DOCKER_HUB_REPO}/voting-app-frontend"

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout SCM') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Lint & Test Backend') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    script {
                        dir('backend') {
                            if (isUnix()) {
                                sh '''
                                    docker run --rm \
                                    -v "$PWD":/app \
                                    -w /app \
                                    node:20-alpine \
                                    sh -c "npm ci && (npm test || true)"
                                '''
                            } else {
                                bat 'docker run --rm -v "%cd%":/app -w /app node:20-alpine sh -c "npm ci && (npm test || true)"'
                            }
                        }
                    }
                }
            }
        }

        stage('Lint & Test Frontend') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    script {
                        dir('frontend') {
                            if (isUnix()) {
                                sh '''
                                    docker run --rm \
                                    -v "$PWD":/app \
                                    -w /app \
                                    node:20-alpine \
                                    sh -c "npm ci && (npm test -- --watchAll=false --coverage || true)"
                                '''
                            } else {
                                bat 'docker run --rm -v "%cd%":/app -w /app node:20-alpine sh -c "npm ci && (npm test -- --watchAll=false --coverage || true)"'
                            }
                        }
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                echo 'Building Docker images...'
                script {
                    dir('backend') {
                        if (isUnix()) {
                            sh """
                                docker build \
                                -t ${BACKEND_IMAGE}:${IMAGE_TAG} \
                                -t ${BACKEND_IMAGE}:latest \
                                .
                            """
                        } else {
                            bat """
                                docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest .
                            """
                        }
                    }

                    dir('frontend') {
                        if (isUnix()) {
                            sh """
                                docker build \
                                --build-arg REACT_APP_API_URL=http://localhost:5000 \
                                -t ${FRONTEND_IMAGE}:${IMAGE_TAG} \
                                -t ${FRONTEND_IMAGE}:latest \
                                .
                            """
                        } else {
                            bat """
                                docker build --build-arg REACT_APP_API_URL=http://localhost:5000 -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest .
                            """
                        }
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running Trivy security scan...'
                script {
                    if (isUnix()) {
                        sh '''
                            if command -v trivy >/dev/null 2>&1; then
                                trivy image --exit-code 0 --severity HIGH,CRITICAL "${BACKEND_IMAGE}:${IMAGE_TAG}" || true
                                trivy image --exit-code 0 --severity HIGH,CRITICAL "${FRONTEND_IMAGE}:${IMAGE_TAG}" || true
                            else
                                echo "Trivy not installed. Skipping scan."
                            fi
                        '''
                    } else {
                        bat '''
                            where trivy >nul 2>&1 && (
                                trivy image --exit-code 0 --severity HIGH,CRITICAL %BACKEND_IMAGE%:%IMAGE_TAG% || exit 0
                                trivy image --exit-code 0 --severity HIGH,CRITICAL %FRONTEND_IMAGE%:%IMAGE_TAG% || exit 0
                            ) || (
                                echo Trivy not installed. Skipping scan.
                            )
                        '''
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                branch 'main'
            }
            steps {
                echo 'Logging into Docker Hub...'
                script {
                    if (isUnix()) {
                        sh '''
                            echo "$DOCKER_HUB_CREDENTIALS_PSW" | docker login \
                            -u "$DOCKER_HUB_CREDENTIALS_USR" \
                            --password-stdin
                        '''
                        sh """
                            docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                            docker push ${BACKEND_IMAGE}:latest
                            docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                            docker push ${FRONTEND_IMAGE}:latest
                        """
                        sh 'docker logout'
                    } else {
                        bat """
                            echo %DOCKER_HUB_CREDENTIALS_PSW% | docker login -u %DOCKER_HUB_CREDENTIALS_USR% --password-stdin
                            docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                            docker push ${BACKEND_IMAGE}:latest
                            docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                            docker push ${FRONTEND_IMAGE}:latest
                            docker logout
                        """
                    }
                }
            }
        }

        stage('Deploy Application') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deploying containers...'
                script {
                    if (isUnix()) {
                        sh '''
                            docker compose down || true
                            docker compose pull
                            docker compose up -d
                        '''
                        sh 'sleep 15'
                        sh 'curl -f http://localhost:80 || exit 1'
                        sh 'curl -f http://localhost:5000/api/health || exit 1'
                    } else {
                        bat '''
                            docker compose down
                            docker compose pull
                            docker compose up -d
                        '''
                        bat 'timeout /t 15 /nobreak'
                        bat 'curl -f http://localhost:80'
                        bat 'curl -f http://localhost:5000/api/health'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning Docker resources...'
            script {
                if (isUnix()) {
                    sh 'docker system prune -f || true'
                } else {
                    bat 'docker system prune -f || exit 0'
                }
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
