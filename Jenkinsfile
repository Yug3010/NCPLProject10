pipeline {
  agent any

  environment {
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    SONAR_TOKEN         = credentials('sonar-token')   
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
          sh '''
            export SONAR_TOKEN=${SONAR_TOKEN}
            export PATH=$PATH:/opt/homebrew/bin
            sonar-scanner -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          export PATH=$PATH:/opt/homebrew/bin
          terraform init
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          export PATH=$PATH:/opt/homebrew/bin
          terraform plan -var="subscription_id=${ARM_SUBSCRIPTION_ID}"
        '''
      }
    }
    
    stage('Terraform Import') {
      steps {
        sh '''
          export PATH=$PATH:/opt/homebrew/bin
          terraform import -var="subscription_id=${ARM_SUBSCRIPTION_ID}" azurerm_policy_definition.custom_policy /subscriptions/${ARM_SUBSCRIPTION_ID}/providers/Microsoft.Authorization/policyDefinitions/enforce-tag-policy || true
        '''
      }
    }

    stage('Terraform Apply') {
      steps {
        sh '''
          export PATH=$PATH:/opt/homebrew/bin
          terraform apply -auto-approve -var="subscription_id=${ARM_SUBSCRIPTION_ID}"
        '''
      }
    }
  }
}
