#!/bin/bash

set -e

echo "Restoring Jenkins jobs..."

JENKINS_HOME_DIR="./jenkins_home"

mkdir -p "$JENKINS_HOME_DIR/jobs/szakdolgozat-pipeline"

cp ./jenkins-jobs-backup/szakdolgozat-pipeline-config.xml "$JENKINS_HOME_DIR/jobs/szakdolgozat-pipeline/config.xml"

echo "Jenkins job restored successfully."
echo ""
echo "Next step:"
echo "docker compose up -d --build"
echo ""
echo "Open Jenkins at:"
echo "http://localhost:8080"
