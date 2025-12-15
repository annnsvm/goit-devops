pipeline {
  agent { label 'kaniko' }

  environment {
    AWS_DEFAULT_REGION = 'us-west-2'                                // ← заміни
    ACCOUNT_ID         = '<account_id>'                              // ← заміни
    ECR_REGISTRY       = "${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
    ECR_REPOSITORY     = 'project-django'
    IMAGE_TAG          = "${env.BUILD_NUMBER}"
    CHART_REPO_URL     = 'https://github.com/your-org/your-helm-repo.git' // ← заміни
    CHART_REPO_BRANCH  = 'main'
    CHART_PATH         = 'charts/django-app'
  }

  stages {
    stage('Checkout App') {
      steps { container('git') { checkout scm } }
    }
    stage('ECR Login') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_DEFAULT_REGION | \
          docker login --username AWS --password-stdin $ECR_REGISTRY
        '''
      }
    }
    stage('Build & Push (Kaniko)') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor --dockerfile=Dockerfile --context=${WORKSPACE} \
              --destination=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG \
              --destination=$ECR_REGISTRY/$ECR_REPOSITORY:latest
          '''
        }
      }
    }
    stage('Bump Helm values.yaml') {
      steps {
        sh '''
          rm -rf chart-repo
          git clone --branch $CHART_REPO_BRANCH $CHART_REPO_URL chart-repo
          cd chart-repo/$CHART_PATH
          python3 - <<'PY'
import yaml
p='values.yaml'
d=yaml.safe_load(open(p))
d.setdefault('image',{})['tag']=str(${IMAGE_TAG})
yaml.safe_dump(d, open(p,'w'), sort_keys=False)
PY
          git config user.email "ci@example.com"
          git config user.name "jenkins-bot"
          git add values.yaml
          git commit -m "chore(ci): bump image tag to ${IMAGE_TAG}"
          git push origin $CHART_REPO_BRANCH
        '''
      }
    }
  }
}
