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
            curl -u ${env.JFROG_CREDS_USR}:${env.JFROG_CREDS_PSW} \\
            -T lambda-package.zip \\
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
              # Temporarily disable backend
              mv backend.tf backend.tf.disabled || true

              # Reconfigure Terraform to ignore existing backend
              terraform init -reconfigure

              # Apply infrastructure
              terraform apply -auto-approve \\
                -var="docker_image=${env.DOCKER_IMAGE}" \\
                -var="lambda_zip_url=${env.JFROG_URL}/lambda-repo/lambda-package-${env.BUILD_NUMBER}.zip" \\
                -var='subnets=["subnet-0b9251120b53a0e5d","subnet-02a8d0c471409b4d4"]' \\
                -var='security_groups=["sg-0cb0d390361af5359"]'
            """
          }
        }
      }
    }
  }
}
