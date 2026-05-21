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
      KUBE_SERVER=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}')
      KUBE_PORT=$(echo $KUBE_SERVER | sed 's/.*://')
      kubectl apply -f k8s/namespace.yaml \
        --server=https://host.docker.internal:${KUBE_PORT} \
        --insecure-skip-tls-verify=true \
        --validate=false
      kubectl apply -f k8s/ \
        --server=https://host.docker.internal:${KUBE_PORT} \
        --insecure-skip-tls-verify=true \
        --validate=false
      kubectl set image deployment/hello-deploy hello=${IMAGE}:${TAG} -n demo \
        --server=https://host.docker.internal:${KUBE_PORT} \
        --insecure-skip-tls-verify=true
      kubectl rollout status deployment/hello-deploy -n demo --timeout=120s \
        --server=https://host.docker.internal:${KUBE_PORT} \
        --insecure-skip-tls-verify=true
      kubectl get svc -n demo -o wide \
        --server=https://host.docker.internal:${KUBE_PORT} \
        --insecure-skip-tls-verify=true
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
