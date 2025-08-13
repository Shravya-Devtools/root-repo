pipeline {
  agent any

  environment {
    GITHUB_CREDS = credentials('GITHUB_CREDENTIALS')
    JFROG_CREDS  = credentials('JFROG_CREDENTIALS')
    AWS_CREDS    = credentials('AWS_CREDENTIALS')

    JFROG_URL    = 'http://130.131.164.192:8082/artifactory'
    DOCKER_IMAGE = "130.131.164.192:8082/docker-repo/nodejs-app:${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/Shravya-Devtools/root-repo.git',
            credentialsId: 'GITHUB_CREDENTIALS'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          docker.build(env.DOCKER_IMAGE, './app')
        }
      }
    }

    stage('Push Docker Image to JFrog') {
      steps {
        script {
          docker.withRegistry("http://130.131.164.192:8082/artifactory/docker-repo", 'JFROG_CREDENTIALS') {
            docker.image(env.DOCKER_IMAGE).push()
          }
        }
      }
    }

    stage('Package Lambda') {
      steps {
        dir('lambda') {
          sh 'zip -r ../lambda-package.zip *'
        }
      }
    }

    stage('Upload Lambda to JFrog') {
      steps {
        script {
          sh """
            curl -u ${env.JFROG_CREDS_USR}:${env.JFROG_CREDS_PSW} \
            -T lambda-package.zip \
            "${env.JFROG_URL}/lambda-repo/lambda-package-${env.BUILD_NUMBER}.zip"
          """
        }
      }
    }

    stage('Terraform Deploy') {
      steps {
        withCredentials([[ 
          $class: 'AmazonWebServicesCredentialsBinding', 
          credentialsId: 'AWS_CREDENTIALS' 
        ]]) {
          dir('terraform') {
            sh """
              mv backend.tf backend.tf.disabled || true
              rm -rf .terraform .terraform.lock.hcl
              terraform init -reconfigure
              terraform apply -auto-approve
            """
          }
        }
      }
    }
  }
}
