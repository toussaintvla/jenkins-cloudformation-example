pipeline {
  agent {
    kubernetes {
    // This is a YAML representation of the Pod, to allow setting any values not supported as fields.
      yamlFile 'k8s/k8sPodTemplate.yaml' // Declarative agents can be defined from YAML.
    }
  }

  parameters {
    string(name: 'STACK_NAME', defaultValue: 'example-stack', description: 'Enter the CloudFormation Stack Name.')
    string(name: 'TEMPLATE_NAME', defaultValue: 'S3-Bucket', description: 'Enter the CloudFormation Template Name (Do not append file extension type.)')
    credentials(name: 'CFN_CREDENTIALS_ID', defaultValue: '', description: 'AWS Account Role.', required: true)
    choice(
      name: 'REGION',
      choices: [
          'us-east-1',
          'us-east-2'
          ],
      description: 'AWS Account Region'
    )
    choice(
      name: 'ACTION',
      choices: ['create-changeset', 'execute-changeset', 'deploy-stack', 'delete-stack'],
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
        expression { params.ACTION == 'create-changeset' }
      }
      steps {
        ansiColor('xterm') {
          script {
            if (params.ACTION == 'create-changeset') {
              env.CHANGESET_MODE = false
            } else {
              env.CHANGESET_MODE = true
            }
          }
        }
      }
    }

    // stage('stack-execution') {
    //   when {
    //     expression { params.ACTION == 'deploy-stack' || params.ACTION == 'execute-changeset' }
    //   }
    //   steps {
    //     ansiColor('xterm') {
    //       container("jenkins-agent") {
    //         withCredentials([[
    //           $class: 'AmazonWebServicesCredentialsBinding',
    //           credentialsId: "${CFN_CREDENTIALS_ID}",
    //           accessKeyVariable: 'AWS_ACCESS_KEY_ID',
    //           secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
    //             sh 'aws sts get-caller-identity'
    //             sh 'cloudformation/deploy-stack.sh ${STACK_NAME} ${TEMPLATE_NAME} ${CHANGESET_MODE} ${REGION}'
    //         }
    //       }
    //     }
    //   }
    // }

    stage('create-changeset') {
      when {
        expression { params.ACTION == 'create-changeset' }
      }
      steps {
        ansiColor('xterm') {
          container("jenkins-agent") {
            sh 'aws sts get-caller-identity'
            sh 'cloudformation/switch-role.sh ${CFN_CREDENTIALS_ID} ${REGION}'
            sh 'cloudformation/deploy-stack.sh ${STACK_NAME} ${TEMPLATE_NAME} ${CHANGESET_MODE} ${REGION}'
            sh 'aws sts get-caller-identity'
          }
        }
      }
    }

    // stage('delete-stack') {
    //   when {
    //     expression { params.ACTION == 'delete-stack' }
    //   }
    //   steps {
    //     ansiColor('xterm') {
    //       container("jenkins-agent") {
    //         withCredentials([[
    //           $class: 'AmazonWebServicesCredentialsBinding',
    //           credentialsId: "${CFN_CREDENTIALS_ID}",
    //           accessKeyVariable: 'AWS_ACCESS_KEY_ID',
    //           secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
    //             sh 'aws sts get-caller-identity'
    //             sh 'cloudformation/delete-stack.sh ${STACK_NAME} ${REGION}'
    //         }
    //       }
    //     }
    //   }
    // }

  }
}