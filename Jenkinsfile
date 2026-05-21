pipeline {
  agent any

  environment {
    DOCKERHUB_CRED = 'docker-hub'
    DOCKERHUB_USER = 'patiess'
    IMAGE          = "${env.DOCKERHUB_USER}/ci-cd-demo"
    TAG            = "${env.BUILD_NUMBER}"
    KUBECONFIG     = '/root/.kube/config'
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15'))
    disableConcurrentBuilds()
  }

  stages {
    stage('Pre-clean (caches + workspace)') {
      steps {
        sh '''
          set -e
          echo "[pre-clean] cache-ek törlése..."
          rm -rf /var/jenkins_home/caches/*git* || true
          rm -rf /var/jenkins_home/caches/scm/* || true
          echo "[pre-clean] kész."
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
        sh '''
          set -e
          echo "Push to Docker Hub skipped (local execution)"
          docker tag ${IMAGE}:${TAG} ${IMAGE}:latest
        '''
      }
    }

    stage('Deploy to K8s') {
      steps {
      sh '''
          set -e
          kubectl apply -f k8s/namespace.yaml --insecure-skip-tls-verify
          kubectl apply -f k8s/ --insecure-skip-tls-verify
          kubectl set image deployment/hello-deploy hello=${IMAGE}:${TAG} -n demo --insecure-skip-tls-verify
          kubectl rollout status deployment/hello-deploy -n demo --timeout=120s --insecure-skip-tls-verify
          kubectl get svc -n demo -o wide --insecure-skip-tls-verify
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
