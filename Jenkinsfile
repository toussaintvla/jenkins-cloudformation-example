// Nested Pipeline
pipeline {
  agent {
    kubernetes {
      yamlFile 'templates/customk8sPodTemplate.yaml'
    }
  }  

  parameters {
    choice(
      choices: ['deploy-stack', 'create-changeset', 'execute-changeset' , 'delete-stack'],
      description: 'CloudFormation Actions',
      name: 'action')
  }

  environment {
    cd1 = true
    cd2 = false
    stack_name = "example-stack"
    template = "prerequisite"
  }

  stages {

    stage('check version') {
      steps {
        ansiColor('xterm') {
          container("custom-image") {
            sh 'aws --version'
          }
        }
      }
    }

    stage('action') {
      when {
        expression { 
          params.action == 'deploy-stack-nonprod' || params.action == 'create-changeset-nonprod' || params.action == 'execute-changeset-nonprod' || params.action == 'delete-stack-nonprod' ||
          params.action == 'deploy-stack-prod' || params.action == 'create-changeset-prod' || params.action == 'execute-changeset-prod' || params.action == 'delete-stack-prod'
        }
      }
      steps {
        ansiColor('xterm') {
          script {
            if ( params.action == 'deploy-stack-nonprod' || params.action == 'execute-changeset-nonprod' ) { 
              account_env = 'awsCredentialsNonProd' 
            } else { 
              account_env = 'awsCredentialsProd' 
            }
          }
        }
      }
    }

    stage('stack-execution') {
      when {
        expression { params.action == 'deploy-stack-nonprod' || params.action == 'execute-changeset-nonprod' || params.action == 'deploy-stack-prod' || params.action == 'execute-changeset-prod' }
      }
      steps {
        ansiColor('xterm') {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${account_env}",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            container("custom-image") {
              sh 'echo ${account_env}'
              sh 'aws sts get-caller-identity'
              sh 'scripts/deploy-stack.sh ${stack_name} ${template} ${cd1}'
            }
          }
        }
      }
    }

    stage('create-changeset') {
      when {
        expression { params.action == 'create-changeset-nonprod' || params.action == 'create-changeset-prod' }
      }
      steps {
        ansiColor('xterm') {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${account_env}",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            container("custom-image") {
              sh 'echo ${account_env}'
              sh 'aws sts get-caller-identity'
              sh 'scripts/deploy-stack.sh ${stack_name} ${template} ${cd2}'
            }
          }
        }
      }
    }

    stage('delete-stack') {
      when {
        expression { params.action == 'delete-stack-nonprod' || params.action == 'delete-stack-prod' }
      }
      steps {
        ansiColor('xterm') {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${account_env}",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            container("custom-image") {
              sh 'echo ${account_env}'
              sh 'aws sts get-caller-identity'
              sh 'scripts/delete-stack.sh ${stack_name}'
            }
          }
        }
      }
    }
  }
}