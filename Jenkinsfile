pipeline {
  agent any

  stages {
    stage('Git clone') {
      steps {
        checkout scmGit(
            branches: [[name: '*/master']], 
            extensions: [], 
            userRemoteConfigs: [[
              url: 'https://github.com/kainlite/devops-project']
            ]
        )
      }
    }

    stage('Running tests with docker') {
      steps {
        catchError (buildResult: 'FAILURE', stageResult: 'FAILURE') {
          sh "echo running unit-tests"
            dir("src") {
              sh 'docker run --name test-postgres --rm -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -d -p 5432:5432 postgres:17-alpine'
              sh 'export DB_IP=`docker inspect test-postgres | jq .[0].NetworkSettings.Networks.bridge.IPAddress -r`; sed -i "s/localhost/${DB_IP}/" main_test.go'
              sh 'docker build -f Dockerfile -t devops-project-test --progress plain --no-cache --target test .'
              sh 'docker stop test-postgres'
            }
        }
      }
    }

    stage('Building docker image') {
      steps {
        sh 'export GIT_SHORT_SHA=`git rev-parse --short HEAD`; cd src && docker build -t devops-project:${GIT_SHORT_SHA} .'
      }
    }

    stage('Pushing image to Docker Hub') {
      steps {
        withCredentials([usernamePassword(
              credentialsId: 'DOCKERHUB_CREDENTIALS', 
              usernameVariable: 'DOCKER_USERNAME', 
              passwordVariable: 'DOCKER_PASSWORD')
        ]) {
          sh '''
            export PROJECT_NAME="devops-project"
            export GIT_SHORT_SHA=`git rev-parse --short HEAD`;
            docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
            docker tag ${PROJECT_NAME}:${GIT_SHORT_SHA} ${DOCKER_USERNAME}/${PROJECT_NAME}:${GIT_SHORT_SHA}
            docker push ${DOCKER_USERNAME}/${PROJECT_NAME}:${GIT_SHORT_SHA}
          '''
        }
      }
    }

    stage('Fetch config and apply changes') {
      steps {
        script {
          withCredentials([usernamePassword(
                credentialsId: 'AWS_CREDENTIALS', 
                usernameVariable: 'AWS_ACCESS_KEY_ID', 
                passwordVariable: 'AWS_SECRET_ACCESS_KEY')
          ]) {
            sh '''
              export AWS_DEFAULT_REGION="us-east-1"
              export GIT_SHORT_SHA=`git rev-parse --short HEAD`;
              export EKS_CLUSTER_NAME=`aws eks list-clusters | jq ".clusters[0]" -r`
              aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_DEFAULT_REGION}
              sed -i "s/replace_me/${GIT_SHORT_SHA}/" manifests/app/01-deployment.yaml
              kustomize build manifests/ | kubectl apply -f -
            '''
          }
        }
      }
    }
  }
}
