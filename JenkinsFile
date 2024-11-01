pipeline {
    agent any

    stages {
        stage('Git clone') {
            steps {
                checkout scmGit(
                  branches: [[name: '*/main']], 
                  extensions: [], 
                  userRemoteConfigs: [[
                    url: 'https://github.com/kainlite/devops-project']
                  ]
                )
            }
        }

        stage('Running tests with docker') {
            steps {
                sh 'cd src && docker build -f Dockerfile -t devops-project-test --progress plain --no-cache --target test .'
            }
        }

        stage('Building docker image') {
            steps {
                sh 'cd src && docker build -t devops-project:${GIT_REVISION,length=7} .'
            }
        }

        stage('Pushing image to ECR') {
            steps {
                withAWS(credentials: 'AWS-CREDENTIALS', region: ${AWS_REGION}) {
                    sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ECR_REPOSITORY}'
                    sh 'docker tag ${PROJECT_NAME}:${GIT_REVISION,length=7} ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:${GIT_REVISION,length=7}'
                    sh 'docker push ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:latest'
                }
            }
        }

        stage('Pushing image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                  credentialsId: DOCKERHUB_CREDENTIALS, 
                  usernameVariable: 'DOCKER_USERNAME', 
                  passwordVariable: 'DOCKER_PASSWORD')
                ]) {
                    sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                    sh 'docker tag ${PROJECT_NAME}:${GIT_REVISION,length=7} ${DOCKERHUB_REPOSITORY}/${PROJECT_NAME}:${GIT_REVISION,length=7}'
                    sh 'docker push ${DOCKERHUB_REPOSITORY}/${PROJECT_NAME}:latest'
                }
            }
        }

        stage('Fetch config and apply changes') {
            steps {
                script {
                    withAWS(credentials: 'AWS-CREDENTIALS', region: ${AWS_REGION}) {
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
