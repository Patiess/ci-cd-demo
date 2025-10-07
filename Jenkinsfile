pipeline {
  agent any

  environment {
    DOCKERHUB_CRED = 'docker-hub'
    DOCKERHUB_USER = 'Patiess'   // <-- ide írd a saját Docker Hub userneved
    IMAGE = "${env.Patiess}/ci-cd-demo"
    TAG   = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build') {
      steps {
        sh 'docker build -t ${IMAGE}:${TAG} .'
      }
    }

    stage('Test') {
      steps {
        sh 'docker run --rm ${IMAGE}:${TAG} || true'
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CRED) {
            sh 'docker push ${IMAGE}:${TAG}'
            sh 'docker tag ${IMAGE}:${TAG} ${IMAGE}:latest'
            sh 'docker push ${IMAGE}:latest'
          }
        }
      }
    }
  }

  post {
    always {
      sh 'docker image prune -f || true'
    }
  }
}
