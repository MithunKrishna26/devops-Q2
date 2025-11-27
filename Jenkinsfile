pipeline {
  agent any

  environment {
    IMAGE_TAG = "routepulse-svc:4"
    CONTAINER_NAME = "routepulse-svc"
    HOST_PORT = "12144"
    CONTAINER_PORT = "12144"
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        echo "Checking out repository..."
        checkout scm
      }
    }

    stage('Pre-check Docker') {
      steps {
        script {
          echo "Verifying Docker CLI and daemon availability..."
          def hasDocker = sh(script: 'which docker >/dev/null 2>&1 && echo "yes" || echo "no"', returnStdout: true).trim()
          if (hasDocker != 'yes') {
            error "Docker CLI not found on agent. Install Docker and ensure 'docker' is in PATH."
          }
          def dockerInfo = sh(script: 'docker info >/dev/null 2>&1 && echo "ok" || echo "nok"', returnStdout: true).trim()
          if (dockerInfo != 'ok') {
            error "Docker daemon is not reachable. Ensure Docker is running and the Jenkins agent can communicate with it."
          }
          echo "Docker is available and daemon is reachable."
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "Building Docker image ${IMAGE_TAG} ..."
        sh "docker build -t ${IMAGE_TAG} ."
      }
    }

    stage('Stop existing container') {
      steps {
        echo "Stopping and removing any running container named ${CONTAINER_NAME} ..."
        sh """
          if [ \$(docker ps -a -q -f name=^/${CONTAINER_NAME}$ | wc -l) -gt 0 ]; then
            docker rm -f ${CONTAINER_NAME} || true
          fi
        """
      }
    }

    stage('Run container') {
      steps {
        echo "Starting container ${CONTAINER_NAME} on host port ${HOST_PORT} ..."
        sh "docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_TAG}"
      }
    }

    stage('Verify service') {
      steps {
        echo "Verifying container is running and responding..."
        sh 'docker ps --filter "name=^/${CONTAINER_NAME}$" --format "table {{.Names}}\\t{{.Image}}\\t{{.Status}}\\t{{.Ports}}"'
        sh """
          sleep 3
          if command -v curl >/dev/null 2>&1; then
            curl -sS -I http://localhost:${HOST_PORT} | head -n 10
          else
            echo "curl not installed on agent; skipping HTTP verification."
          fi
        """
      }
    }
  }

  post {
    success {
      echo "Pipeline succeeded: image ${IMAGE_TAG} built and container ${CONTAINER_NAME} running on port ${HOST_PORT}."
    }
    failure {
      echo "Pipeline failed. Inspect logs above."
    }
    always {
      sh """
        echo '--- container logs (last 50 lines) ---'
        docker logs --tail 50 ${CONTAINER_NAME} || true
      """
    }
  }
}
