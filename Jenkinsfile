pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15'))
    disableConcurrentBuilds()
  }

  environment {
    DOCKERHUB_CRED = 'docker-hub'
    DOCKERHUB_USER = 'patiess'
    IMAGE          = "${env.DOCKERHUB_USER}/ci-cd-demo"
    TAG            = "${env.BUILD_NUMBER}"
    KUBECONFIG     = '/var/jenkins_home/.kube/config'
  }

  stages {
    stage('Pre-clean (caches + workspace)') {
      steps {
        sh '''
          set -e
          rm -rf /var/jenkins_home/caches/* || true
        '''
        deleteDir()
      }
    }

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build') {
      steps {
        sh '''
          set -e
          export DOCKER_BUILDKIT=0
          docker build -t ${IMAGE}:${TAG} .
        '''
      }
    }

    stage('Test (container smoke)') {
      steps {
        sh '''
          set -e
          docker rm -f ci-cd-demo-test || true
          docker run -d --name ci-cd-demo-test -p 8088:80 ${IMAGE}:${TAG}
          sleep 3
          curl -fsS http://host.docker.internal:8088/ | tee /tmp/test_output.txt
          docker rm -f ci-cd-demo-test
        '''
      }
    }

    stage('Security scan (Trivy)') {
      steps {
        sh '''
          set -e
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest image \
              --quiet \
              --exit-code 0 \
              --severity CRITICAL,HIGH \
              ${IMAGE}:${TAG} || true
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CRED) {
            sh '''
              set -e
              docker push ${IMAGE}:${TAG}
              docker tag  ${IMAGE}:${TAG} ${IMAGE}:latest
              docker push ${IMAGE}:latest
            '''
          }
        }
      }
    }

    stage('Deploy to K8s') {
      steps {
        sh '''
          set -e
          kubectl apply -f k8s/namespace.yaml || true
          kubectl apply -f k8s/
          kubectl set image deployment/hello-deploy hello=${IMAGE}:${TAG} --record || true
          kubectl -n demo rollout status deployment/hello-deploy --timeout=120s
          kubectl -n demo get svc -o wide
        '''
      }
    }
  }

  post {
    always {
      sh 'docker image prune -f || true'
    }
  }
}
