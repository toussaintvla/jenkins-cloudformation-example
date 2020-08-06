// Nested Pipeline
pipeline {
  agent {
    kubernetes {
      yamlFile 'templates/customk8sPodTemplate.yaml'
    }
  }  

  environment {
    var = 'sample.tfvars'
  }

  parameters {
    choice(
      choices: ['plan', 'apply' , 'show', 'preview-destroy' , 'destroy'],
      description: 'Terraform actions',
      name: 'action')
    }

    stages {

      stage('Check Version') {
        steps {
          ansiColor('xterm'){
            container("custom-image") {
              sh 'terraform --version'
            }
          }
        }
      }

      stage('init'){
        steps {
          ansiColor('xterm'){
              container("custom-image") {
              // cleanWs()
                sh 'aws sts get-caller-identity'
                sh 'terraform init -reconfigure'
              } 
            }
          }
        }

        stage('validate'){
          when {
            expression { params.action == 'preview' || params.action == 'apply' || params.action == 'destroy' }
          }

          steps {
            ansiColor('xterm'){ 
                container("custom-image") {
                  sh 'terraform validate --var-file=${var}'
                } 
              }
            }
          }

          stage('plan'){
            when {
              expression { params.action == 'plan' }
            }

            steps {
              ansiColor('xterm'){
                  container("custom-image") {
                    sh 'terraform plan --var-file=${var}'
                  }
                }
              }
            }
            stage('apply'){
              when {
                expression { params.action == 'apply' }
              }
              steps {
                ansiColor('xterm'){
                    container("custom-image") {
                      sh 'aws sts get-caller-identity'
                      sh 'terraform plan --var-file=${var}'
                      sh 'terraform apply -auto-approve --var-file=${var}'
                    }
                  }
                }
              }

              stage('show') {
                when {
                  expression { params.action == 'show' }
                }
                steps {
                  ansiColor('xterm'){
                      container("custom-image") {
                        sh 'terraform show'
                      }
                    }
                  }
                }

                stage('preview-destroy') {
                  when {
                    expression { params.action == 'preview-destroy' }
                  }
                  steps {
                    ansiColor('xterm'){
                        container("custom-image") {
                          sh 'terraform plan -destroy --var-file=${var}'
                        }
                      }
                    }
                  }

                  stage('destroy') {
                    when {
                      expression { params.action == 'destroy' }
                    }
                    steps {
                      ansiColor('xterm'){
                          container("custom-image") {
                            sh 'terraform destroy -force --var-file=${var}'
                          }
                        }
                      }
                    }
                  }
                }
