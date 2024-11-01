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
                credentialsId: DOCKERHUB_CREDENTIALS, 
                usernameVariable: 'DOCKER_USERNAME', 
                passwordVariable: 'DOCKER_PASSWORD')
          ]) {
            sh '''
              export GIT_SHORT_SHA=`git rev-parse --short HEAD`;
            docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
              docker tag ${PROJECT_NAME}:${GIT_SHORT_SHA} ${DOCKERHUB_REPOSITORY}/${PROJECT_NAME}:${GIT_SHORT_SHA}
            docker push ${DOCKERHUB_REPOSITORY}/${PROJECT_NAME}:latest
              '''
          }
        }
      }

      stage('Fetch config and apply changes') {
        steps {
          script {
            withAWS(credentials: 'AWS-CREDENTIALS', region: "${AWS_REGION}") {
              sh 'aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}'
                sh 'sed -i "s/replace_me/${GIT_REVISION,length=7}/" manifests/00-appspec.yaml'
                sh 'kubectl apply -f manifests/00-appspec.yaml'
            }
          }
        }
      }

      stage('LB URL') {
        steps {
          script {
            def serviceUrl = ""

              timeout(time: 2, unit: 'MINUTES') {
                while(serviceUrl == "") {
                  serviceUrl = sh(script: "kubectl get svc ${PROJECT_NAME}-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()
                    if(serviceUrl == "") {
                      echo "Waiting for the LoadBalancer IP..."
                        sleep 10
                    }
                }
              }

            echo "Load balance URL: http://${serviceUrl}"
          }
        }
      }
    }
}
