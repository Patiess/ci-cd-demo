pipeline {
  agent any
  environment {
    IMAGE = "ci-cd-demo-local"
    TAG   = "${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout'){ steps { checkout scm } }
    stage('Build image'){ steps { sh 'docker build -t ${IMAGE}:${TAG} .' } }
    stage('Test run'){ steps { sh 'docker run --rm ${IMAGE}:${TAG}' } }
  }
  post { always { sh 'docker image prune -f || true' } }
}
