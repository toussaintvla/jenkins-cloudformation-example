pipeline {
  agent {
    kubernetes {
    // This is a YAML representation of the Pod, to allow setting any values not supported as fields.
      yamlFile 'k8s/k8sPodTemplate.yaml' // Declarative agents can be defined from YAML.
    }
  }

  parameters {
    string(name: 'stack_name', defaultValue: 'example-stack', description: 'Enter the CloudFormation Stack Name')
    string(name: 'template_name', defaultValue: 'S3-Bucket', description: 'Enter the CloudFormation Template Name (Do not append file extension type.)')
    string(name: 'account_env', defaultValue: '', description: 'AWS Account ID')
    choice(
      name: 'region',
      choices: [
          'us-east-1',
          'us-east-2'
          ],
      description: 'AWS Account Region'
    )
    choice(
      name: 'action',
      choices: ['deploy-stack', 'create-changeset', 'execute-changeset', 'delete-stack'],
      description: 'CloudFormation Actions'
    )
    booleanParam(name: 'TOGGLE', defaultValue: false, description: 'Are you sure you want to perform this action?')
  }

  stages {

    stage('check version') {
      steps {
        ansiColor('xterm') {
          container("jenkins-agent") {
            sh 'aws --version'
            sh 'aws sts get-caller-identity'
          }
        }
      }
    }

    stage('action') {
      when {
        expression { params.action == 'create-changeset' }
      }
      steps {
        ansiColor('xterm') {
          script {
            if (params.action == 'create-changeset') {
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
        expression { params.action == 'deploy-stack' || params.action == 'execute-changeset' }
      }
      steps {
        ansiColor('xterm') {
          container("jenkins-agent") {
            withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: "${account_env}",
              accessKeyVariable: 'AWS_ACCESS_KEY_ID',
              secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh 'aws sts get-caller-identity'
                sh 'cloudformation/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode} ${region}'
            }
          }
        }
      }
    }

    stage('create-changeset') {
      when {
        expression { params.action == 'create-changeset' }
      }
      steps {
        ansiColor('xterm') {
          container("jenkins-agent") {
            withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: "${account_env}",
              accessKeyVariable: 'AWS_ACCESS_KEY_ID',
              secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh 'aws sts get-caller-identity'
                sh 'cloudformation/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode} ${region}'
            }
          }
        }
      }
    }

    stage('delete-stack') {
      when {
        expression { params.action == 'delete-stack' }
      }
      steps {
        ansiColor('xterm') {
          container("jenkins-agent") {
            withCredentials([[
              $class: 'AmazonWebServicesCredentialsBinding',
              credentialsId: "${account_env}",
              accessKeyVariable: 'AWS_ACCESS_KEY_ID',
              secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh 'aws sts get-caller-identity'
                sh 'cloudformation/delete-stack.sh ${stack_name} ${region}'
            }
          }
        }
      }
    }

  }
}