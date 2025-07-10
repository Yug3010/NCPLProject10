pipeline {
  agent any

  environment {
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    TF_IN_AUTOMATION    = 'true'
    SONARQUBE_ENV       = 'SonarQubeServer'
  }

  tools {
    terraform 'Terraform-latest'
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/Yug3010/NCPLProject10'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv("${SONARQUBE_ENV}") {
          sh 'sonar-scanner'
        }
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -var="subscription_id=$ARM_SUBSCRIPTION_ID"'
      }
    }

    stage('Terraform Apply') {
      steps {
        sh 'terraform apply -auto-approve -var="subscription_id=$ARM_SUBSCRIPTION_ID"'
      }
    }
  }
}
