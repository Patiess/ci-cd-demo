pipeline {
  agent any

  environment {
    DOCKERHUB_CRED = 'docker-hub'
    DOCKERHUB_USER = 'patiess'
    IMAGE = "${env.DOCKERHUB_USER}/ci-cd-demo"
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
        sh 'docker run --rm ${IMAGE}:${TAG}'
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

    // 🔽🔽🔽 IDE jön most a K8s deploy stage 🔽🔽🔽
    stage('Deploy to K8s') {
      steps {
        withEnv(['KUBECONFIG=/var/jenkins_home/.kube/config']) {
          sh 'kubectl get nodes'
          sh 'kubectl apply -f k8s/'
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
