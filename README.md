# Szakdolgozat - Automatizált CI/CD Pipeline Környezet

Ez a projekt a szakdolgozat gyakorlati részét képező demonstrációs környezet, amely egy teljes körű CI/CD folyamatot valósít meg Jenkins, Docker és Kubernetes technológiák integrációjával.

## Előfeltételek

* Telepített és futó Docker Desktop alkalmazás.
* Engedélyezett Kubernetes modul a Docker Desktop beállításaiban.

## Futtatási útmutató

1. Környezet előkészítése
A Jenkins konténer lokális Kubernetes klaszterhez való hitelesítéséhez futtassa az alábbi parancsokat a projekt gyökerében:
`chmod +x setup.sh`
`./setup.sh`

2. Infrastruktúra indítása
Indítsa el a Jenkins szervert a Docker Compose segítségével:
`docker-compose up -d`

3. Jenkins konfiguráció és Pipeline futtatás
* Nyissa meg a böngészőben a http://localhost:8080 címet.
* Hozzon létre egy új Pipeline típusú projektet.
* A konfiguráció során a Definition mezőben válassza a Pipeline script from SCM opciót.
* SCM-nek válassza a Git lehetőséget, és adja meg a repository URL-jét.
* A mentést követően indítsa el a folyamatot a Build Now gombbal.

4. Eredmény ellenőrzése
A sikeres lefutást követően az alkalmazás az alábbi címen érhető el:
http://localhost:30242