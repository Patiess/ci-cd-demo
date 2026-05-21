#!/bin/bash

echo "Kubernetes konfiguráció másolása..."
mkdir -p ./jenkins_home/.kube
cp ~/.kube/config ./jenkins_home/.kube/config

sed -i '' 's/127.0.0.1/host.docker.internal/g' ./jenkins_home/.kube/config
sed -i '' 's/localhost/host.docker.internal/g' ./jenkins_home/.kube/config

echo "Jenkins job visszaállítása..."
mkdir -p ./jenkins_home/jobs/szakdolgozat-pipeline
cp ./jenkins-jobs-backup/szakdolgozat-pipeline-config.xml ./jenkins_home/jobs/szakdolgozat-pipeline/config.xml

echo "Környezet és Jenkins job sikeresen előkészítve a vizsgához!"