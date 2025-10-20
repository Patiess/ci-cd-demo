pipeline {
  agent any

  options {
    // ne legyen automatikus checkout a node-ra; mi intézzük
    skipDefaultCheckout(true)
    // logokban időbélyeg jól jön
    timestamps()
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
        // Git/SCM cache-ek takarítása a Jenkins konténerben
        sh '''
          set -e
          echo "[pre-clean] cache-ek törlése..."
          rm -rf /var/jenkins_home/caches/*git* 2>/dev/null || true
          rm -rf /var/jenkins_home/caches/scm/* 2>/dev/null || true
          echo "[pre-clean] kész."
        '''
        // aktuális workspace teljes törlése
        deleteDir()
      }
    }

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build') {
      steps {
        sh '''
          export DOCKER_BUILDKIT=1
          docker build --progress=plain -t ${IMAGE}:${TAG} .
        '''
      }
    }

    // a Flask szerver nem áll le magától: háttérben futtatjuk, ellenőrizzük, leállítjuk
    stage('Test') {
      steps {
        sh '''
          set -e
          docker rm -f ci-cd-demo-test || true
          docker run -d --name ci-cd-demo-test -p 8088:80 ${IMAGE}:${TAG}
          sleep 3
          curl -fsS http://127.0.0.1:8088/ | tee /tmp/test_output.txt
          docker rm -f ci-cd-demo-test
        '''
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CRED) {
            sh '''
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
          kubectl apply -f k8s/
          kubectl set image deployment/hello-deploy hello=${IMAGE}:${TAG} --record || true
          kubectl rollout status deployment/hello-deploy --timeout=120s
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
