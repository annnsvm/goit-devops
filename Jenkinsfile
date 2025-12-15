pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
    - name: git
      image: alpine/git
      command:
        - sleep
      args:
        - 99d
"""
        }
    }

    environment {
        ECR_REGISTRY = "307987835663.dkr.ecr.eu-north-1.amazonaws.com"
        IMAGE_NAME = "django-app"
        IMAGE_TAG = "1.0.${BUILD_NUMBER}"

        COMMIT_EMAIL = "jenkins@localhost"
        COMMIT_NAME = "jenkins"
    }

    stages {
        stage('Build & Push Docker Image') {
            steps {
                container('kaniko') {
                    sh '''
            REPO_DIR="$(pwd)"
            /kaniko/executor \\
              --context "${REPO_DIR}/django" \\
              --dockerfile "${REPO_DIR}/django/Dockerfile" \\
              --destination="$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG" \\
              --cache=true \\
              --insecure \\
              --skip-tls-verify
          '''
                }
            }
        }

        stage('Update Chart Tag in Git') {
            steps {
                container('git') {
                    withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PAT')]) {
                        sh '''
              git clone --branch final-project --depth 1 https://github.com/KryvkoSergii/goit-devops.git goit-devops
              cd goit-devops/charts/django-app

              sed -i "s/tag: .*/tag: $IMAGE_TAG/" values.yaml

              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"

              git add values.yaml
              git commit -m "Update image tag to $IMAGE_TAG"

              git remote set-url origin "https://${GIT_USERNAME}:${GIT_PAT}@github.com/KryvkoSergii/goit-devops.git"

              git push origin HEAD:final-project
            '''
                    }
                }
            }
        }
    }
}
