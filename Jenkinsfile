pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        DOCKER_IMAGE = "balaji2795/javaapp"
        DOCKER_TAG = "${BUILD_NUMBER}"
        NEXUS_URL = "http://43.204.38.235:8081"
        SONARQUBE_ENV = "sonar-server"   // MUST match Jenkins config
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master',
                    credentialsId: 'git-creds',
                    url: 'https://github.com/Balaji2795/multibranch-javaapp.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean verify'
            }
        }

    stage('SonarQube Analysis') {
    steps {
       withSonarQubeEnv('sonar-server') {
    sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=myweb'
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

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Upload to Nexus') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus-creds',
                    usernameVariable: 'NEXUS_USER',
                    passwordVariable: 'NEXUS_PASS'
                )]) {
                    sh """
                    mvn deploy \
                    -Dnexus.username=$NEXUS_USER \
                    -Dnexus.password=$NEXUS_PASS
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                    kubectl set image deployment/javaapp javaapp=${DOCKER_IMAGE}:${DOCKER_TAG} --record
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
