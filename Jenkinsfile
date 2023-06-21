pipeline {
  environment {
    SCANNER_HOME = tool 'sonarqube'    
    CHART_VERSION = "0.7.${BUILD_NUMBER}"
    REPOSITORY = "github.com/e6x-labs/e6data-workspace.git"
  }

  agent {
    kubernetes {
      defaultContainer 'jnlp'
    }
  }

  options { 
    disableConcurrentBuilds()
    skipDefaultCheckout()
  }

  stages{
    // stage('SonarQube Analysis') {
    //     checkout scm
    //     steps{
    //         withSonarQubeEnv('sonarqube-jenkins') {
    //             sh 'export SONAR_SCANNER_OPTS=-Xmx2048m' 
    //             sh '${SCANNER_HOME}/bin/sonar-scanner'
    //         }
    //     }
    // }

    stage('AWS build') {
      agent {
        kubernetes {
          inheritFrom 'helmdeploy'
          defaultContainer 'jnlp'
        }
      }

      when {
      branch 'main'
      }

      steps { 
        checkout scm
        sh 'git checkout main'
        dir ('charts') {
          container('helm') {
            sh 'sed -i "s/version:.*/version: ${CHART_VERSION}/" workspace/Chart.yaml'
            sh 'rm -rf workspace/*.tgz'
            sh 'helm package workspace'
            sh 'mv e6data-workspace-${CHART_VERSION}.tgz workspace/'
            sh 'helm repo index workspace --url https://e6x-labs.github.io/e6data-workspace/'
          }
        }  
        withCredentials([usernamePassword(credentialsId: 'repo_access', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
          sh 'git config user.email "srinath@e6data.com"'
          sh 'git config user.name "e6data CI"'
          sh 'git add .'
          sh 'git status'
          sh 'git commit -a -m "Jenkins build ${BUILD_NUMBER}"'
          sh 'git tag -m "Jenkins build ${BUILD_NUMBER}" -a ${CHART_VERSION}'
          sh 'git push https://${GIT_USERNAME}:${GIT_PASSWORD}@${REPOSITORY} origin main'
          sh 'git push https://${GIT_USERNAME}:${GIT_PASSWORD}@${REPOSITORY} ${CHART_VERSION}'
        }
      }
    }
  }
}    
