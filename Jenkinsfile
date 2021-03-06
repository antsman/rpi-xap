#!/groovy

pipeline {
    agent any
    environment {
        DOCKER_CREDS = credentials('DOCKER_HUB_CREDS')
        IMAGE_NAME = 'antsman/rpi-xap'
        IMAGE_TAG = "ci-jenkins-$BRANCH_NAME"
        CONTAINER_NAME = "$BUILD_TAG"
    }
    stages {
        stage('BUILD') {
            steps {
                sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
            }
        }
        stage('TEST') {
            steps {
                sh "docker run -d --rm --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_TAG"
                // Get hah, os version in started container, store in version.properties
                sh "./get-versions.sh $CONTAINER_NAME"
                load './version.properties'
                echo "$HAH_VERSION"
                echo "$OS_VERSION"
                // Check for hub listening on default port
                sh 'date'
                sleep 60
                sh "docker exec -t $CONTAINER_NAME netstat -ulp | grep :3639 | grep xap-hub"
                sh "time docker stop $CONTAINER_NAME"
            }
        }
        stage('PUSH') {
            when {
                branch 'master'
            }
            steps {
                sh "docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest"
                sh "docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:$HAH_VERSION"
                sh "docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:$HAH_VERSION-$OS_VERSION"

                sh "echo $DOCKER_CREDS_PSW | docker login --username $DOCKER_CREDS_USR --password-stdin"

                sh "docker push $IMAGE_NAME:latest"
                sh "docker push $IMAGE_NAME:$HAH_VERSION"
                sh "docker push $IMAGE_NAME:$HAH_VERSION-$OS_VERSION"
            }
        }
    }
    post {
        failure {
            sh "docker rm -f $CONTAINER_NAME"
        }
    }
}
