CI/CD Pipeline – Szakdolgozat
Juszkó Patrik
Technológiák: Jenkins, Docker, Kubernetes, Python Flask, Trivy

Előfeltételek

Docker Desktop telepítve és futtatva
Kubernetes engedélyezve: Settings → Kubernetes → Enable Kubernetes → Apply & Restart
Várj amíg mindkét jelzőlámpa zöld (Docker + Kubernetes)


Telepítés és indítás
Csomagold ki a ZIP fájlt az Asztalra szakdolgozat névvel, majd futtasd PowerShellben:
powershellcd "$env:USERPROFILE\Desktop\szakdolgozat"
docker-compose up -d --build
Az első indítás 3-5 percet vesz igénybe.

Jenkins megnyitása
http://localhost:8080
A szakdolgozat-pipeline job automatikusan létrejön. Kattints a Build Now gombra.

Az alkalmazás elérése
Sikeres futás után:
http://localhost:8081

Projekt struktúra
szakdolgozat/
├── app.py                    # Flask webalkalmazás
├── Dockerfile                # Alkalmazás image
├── Dockerfile.jenkins        # Jenkins image
├── docker-compose.yml        # Indítási konfiguráció
├── Jenkinsfile               # CI/CD pipeline
├── jenkins-jobs-backup/      # Pipeline job konfiguráció
└── k8s/                      # Kubernetes manifesztek
