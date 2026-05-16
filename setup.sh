#!/bin/bash
mkdir -p ./jenkins_home/.kube
cp ~/.kube/config ./jenkins_home/.kube/config
# Kicseréljük az IP-ket, hogy a konténer lássa a Mac-et
sed -i '' 's/127.0.0.1/host.docker.internal/g' ./jenkins_home/.kube/config
sed -i '' 's/localhost/host.docker.internal/g' ./jenkins_home/.kube/config
echo "Környezet előkészítve a szakdolgozathoz!"
