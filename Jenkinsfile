// Nested Pipeline
pipeline {
  agent {
    kubernetes {
      yamlFile 'templates/customk8sPodTemplate.yaml'
    }
  }  

  parameters {
    choice(
      choices: [
        'deploy-stack-nonprod', 'create-changeset-nonprod', 'execute-changeset-nonprod', 'delete-stack-nonprod',
        'deploy-stack-prod', 'create-changeset-prod', 'execute-changeset-prod', 'delete-stack-prod'
      ],
      description: 'CloudFormation Actions',
      name: 'action'
    )
  }

  environment {
    changeset_mode = true
    account_env = 'awsCredentialsNonProd'
    stack_name = "example-stack"
    template_name = "prerequisite"
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
            if ( params.action == 'deploy-stack-prod' || params.action == 'create-changeset-prod' || params.action == 'execute-changeset-prod' || params.action == 'delete-stack-prod' ) { 
              env.account_env = 'awsCredentialsProd'
            }
            if ( params.action == 'create-changeset-nonprod' || params.action == 'create-changeset-prod' ) {
              env.changeset_mode = false
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
              sh 'aws sts get-caller-identity'
              sh 'scripts/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode}'
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
              sh 'aws sts get-caller-identity'
              sh 'scripts/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode}'
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
              sh 'aws sts get-caller-identity'
              sh 'scripts/delete-stack.sh ${stack_name}'
            }
          }
        }
      }
    }
  }
}