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
        expression { params.action == 'deploy-stack' || params.action == 'delete-stack' }
      }
      steps {
        ansiColor('xterm'){
          container("custom-image") {
            sh 'ls -l'
          }
        }
      }
    }

    stage('deploy-stack') {
      when {
        expression { params.action == 'deploy-stack' }
      }
      steps {
        ansiColor('xterm') {
            container("custom-image") {
              sh 'scripts/deploy-stack.sh prerequisite prerequisite default'
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
            sh './delete-stack.sh prerequisite default'
          }
        }
      }
    }
  }
}
