pipeline {
  agent {
    kubernetes {
      yamlFile 'k8s/k8sPodTemplate.yaml' // Declarative agents can be defined from YAML.
      // This is a YAML representation of the Pod, to allow setting any values not supported as fields.
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
    stack_name = "example-stack"
    template_name = "S3-Bucket"
    region = "us-east-1"
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
            } else {
              env.account_env = 'awsCredentialsNonProd'
            }
            if ( params.action == 'create-changeset-nonprod' || params.action == 'create-changeset-prod' ) {
              env.changeset_mode = false
            } else {
              env.changeset_mode = true
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
              sh 'cloudformation/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode} ${region}'
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
              sh 'cloudformation/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode} ${region}'
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
              sh 'cloudformation/delete-stack.sh ${stack_name} ${region}'
            }
          }
        }
      }
    }
  }
}