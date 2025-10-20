pipeline {
  agent any

  // fontos: ne legyen implicit (lightweight) checkout
  options {
    skipDefaultCheckout(true)
    timestamps()
  }

  parameters {
    booleanParam(name: 'NIGHTLY', defaultValue: false, description: 'Éjszakai csomagolás és outbox ürítés')
  }

  environment {
    BASE = '/var/jenkins_home/fileflow'
  }

  stages {

    stage('Checkout') {
      steps {
        // tiszta workspace és explicit, teljes klón
        deleteDir()
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/Patiess/ci-cd-demo.git',
            credentialsId: 'github-pat-2'
          ]]
        ])
      }
    }

    stage('Init dirs') {
      steps {
        sh '''
          set -eu
          mkdir -p "$BASE"/inbox "$BASE"/fe "$BASE"/bo "$BASE"/outbox "$BASE"/archive "$BASE"/logs
          mkdir -p "$BASE"/processing/invoices "$BASE"/processing/messages "$BASE"/processing/reports "$BASE"/processing/texts
          echo "Könyvtárstruktúra:"
          ls -l "$BASE" || true
        '''
      }
    }

    stage('Route files') {
      steps {
        sh '''
          set -eu

          any=0
          for f in "$BASE/inbox"/*; do
            [ -e "$f" ] || break
            any=1

            name=$(basename "$f")
            case "$name" in
              *.inv) type="invoices"; target_side="bo" ;;
              *.msg) type="messages"; target_side="fe" ;;
              *.rpt) type="reports";  target_side="bo" ;;
              *.txt) type="texts";    target_side="fe" ;;
              *)     echo "Ismeretlen kiterjesztés, kihagyva: $name"; continue ;;
            esac

            mv "$f" "$BASE/processing/$type/$name"
            cp -f "$BASE/processing/$type/$name" "$BASE/$target_side/" 2>/dev/null || true
            echo "Routolva: $name -> processing/$type (+ $target_side)"
          done

          if [ "$any" -eq 0 ]; then
            echo "Nincs mit mozgatni az inbox-ban."
          fi

          echo "Állapot a routing után:"
          echo "# inbox";      ls -l "$BASE/inbox"      || true
          echo "# processing"; ls -l "$BASE/processing" || true
          echo "# fe";         ls -l "$BASE/fe"         || true
          echo "# bo";         ls -l "$BASE/bo"         || true
        '''
      }
    }

    stage('Simulate containers (process -> outbox)') {
      steps {
        sh '''
          set -eu

          for type in invoices messages reports texts; do
            OUT="$BASE/outbox/${type}.txt"
            : > "$OUT"

            for f in "$BASE/processing/$type"/*; do
              [ -e "$f" ] || break
              [ -f "$f" ] || continue
              echo ">> $(basename "$f")" >> "$OUT"
              cat "$f" >> "$OUT"
              printf "\\n----\\n" >> "$OUT"
            done
          done

          echo "Outbox tartalma:"
          ls -l "$BASE/outbox" || true
        '''
      }
    }

    stage('Nightly package (optional)') {
      when { expression { return params.NIGHTLY?.toString() == 'true' } }
      steps {
        sh '''
          set -eu
          ts=$(date +%Y%m%d-%H%M%S)
          pkg="$BASE/archive/pkg-$ts.tgz"
          tar -czf "$pkg" -C "$BASE/outbox" . 2>/dev/null || true
          echo "Csomag készült: $pkg"
          find "$BASE/outbox" -type f -delete || true
          echo "Archive:"
          ls -lh "$BASE/archive" || true
        '''
      }
    }
  }

  post {
    success { echo 'Fileflow pipeline: SUCCESS' }
    failure { echo 'Fileflow pipeline: FAILURE' }
    always  { echo 'Kész.' }
  }
}
