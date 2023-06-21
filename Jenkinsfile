String cron_string = BRANCH_NAME == "main" ? "* * * * *" : ""

pipeline {
  environment {
    RELEASE_NAME = "e6data-workspace"
    SCANNER_HOME = tool 'sonarqube'
    
    CHART_VERSION = "v0.7.${BUILD_NUMBER}"

    REPOSITORY = "github.com/e6x-labs/e6data-workspace.git"
  }

  agent {
    kubernetes {
      defaultContainer 'jnlp'
    }
  }

  options { 
    disableConcurrentBuilds()
  }

  stages{
    stage('SonarQube Analysis') {
        steps{
            withSonarQubeEnv('sonarqube-jenkins') {
                sh 'export SONAR_SCANNER_OPTS=-Xmx2048m' 
                sh '${SCANNER_HOME}/bin/sonar-scanner'
            }
        }
    }

    stage('AWS build') {
        agent {
        kubernetes {
            inheritFrom 'helmdeploy'
            defaultContainer 'helm'
        }
        }

        when {
        branch 'main'
        }

        steps { 
            
        dir ('charts/workspace') {
            sh 'helm package .'
            sh 'helm repo index . --url https://e6x-labs.github.io/e6data-workspace/'
            sh 'mkdir -p services/terraform_templates/values/'
            sh 'tar zxvf e6-terraform.tar.gz -C services/terraform_templates/'
            sh 'rm -rf ./services/terraform_templates/providers.tf'
            sh 'rm -rf ./services/terraform_templates/output.tf'
            sh 'rm -rf ./services/terraform_templates/values.tfvars'
            sh 'rm -rf ./e6-terraform.tar.gz'
            sh 'docker build --no-cache --network=host -t $AWS_CONTAINER_IMAGE .'
            sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com'
            sh 'docker push $AWS_CONTAINER_IMAGE'
        }
        }
    }

    stage('Git tagging') {
      when {
        branch 'main'
        // changeset "cluster/*"
      }

      steps {
        checkout scm

        script {
          env.GITCOMMIT=sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
        }

        sh 'git config user.email "ci@e6xlabs.cloud"'
        sh 'git config user.name "Jenkins CI"'
        withCredentials([usernamePassword(credentialsId: 'repo_access', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
            sh 'git tag -m \"commit id: ${GITCOMMIT} docker build: ${IMAGE_VERSION}\" -a ${RELEASE_NAME}-${IMAGE_VERSION}'
            sh 'git push https://${GIT_USERNAME}:${GIT_PASSWORD}@${REPOSITORY} ${RELEASE_NAME}-${IMAGE_VERSION}'
        }
      }
    }
  }
}
