pipeline {
  agent any

  environment {
    DOCKERHUB_CRED = 'docker-hub'
    DOCKERHUB_USER = 'patiess'
    IMAGE          = "${env.DOCKERHUB_USER}/ci-cd-demo"
    TAG            = "${env.BUILD_NUMBER}"
    KUBECONFIG     = '/var/jenkins_home/.kube/config'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build') {
      steps {
        sh '''
          export DOCKER_BUILDKIT=1
          docker build --progress=plain -t ${IMAGE}:${TAG} .
        '''
      }
    }

    // ⚠️ A Flask szerver nem lép ki, ezért háttérben futtatjuk, curl-lel ellenőrizzük, majd leállítjuk
    stage('Test') {
      steps {
        sh '''
          set -e
          docker rm -f ci-cd-demo-test || true
          docker run -d --name ci-cd-demo-test -p 8088:80 ${IMAGE}:${TAG}
          # adjunk időt az indulásra
          sleep 3
          # várjuk, hogy 200-at adjon vissza és kapjunk tartalmat
          curl -fsS http://127.0.0.1:8088/ | tee /tmp/test_output.txt
          # takarítás
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
          # K8s objektumok alkalmazása
          kubectl apply -f k8s/
          # Új image kiadása (ha a Deployment már létezik)
          kubectl set image deployment/hello-deploy hello=${IMAGE}:${TAG} --record || true
          # Várunk a rollout befejezésére max 2 percet
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
