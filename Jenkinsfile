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
    condition: false
    stack_name: "prerequisite"
    template: "prerequisite"
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

    stage('check identity') {
      steps {
        ansiColor('xterm') {
          container("custom-image") {
            sh 'aws sts get-caller-identity'
          } 
        }
      }
    }

    stage('action') {
      when {
        expression { params.action == 'deploy-stack' || params.action == 'create-changeset' || params.action == 'execute-changeset' || params.action == 'delete-stack' }
      }
      steps {
        ansiColor('xterm'){
          container("custom-image") {
            sh 'ls -l'
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
            container("custom-image") {
              sh 'scripts/deploy-stack.sh ${stack_name} ${template} ${condition}'
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
            container("custom-image") {
              sh 'scripts/deploy-stack.sh ${stack_name} ${template} ${condition}'
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
          container("custom-image") {
            sh 'scripts/delete-stack.sh ${stack_name}'
          }
        }
      }
    }
  }
}