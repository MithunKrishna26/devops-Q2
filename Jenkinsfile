pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare / Build') {
            steps {
                echo "Checking Python and creating virtual environment..."
                sh '''
                    # Ensure python3 exists
                    command -v python3 || { echo "python3 not found"; exit 1; }

                    # Create venv
                    python3 -m venv venv

                    # Activate venv
                    . venv/bin/activate

                    # Upgrade pip
                    pip install --upgrade pip

                    # Install dependencies
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                echo "Running Unit Tests (before deploy)..."
                sh '''
                    . venv/bin/activate
                    python -m unittest discover -s .
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying application..."
                sh '''
                    mkdir -p python-app-deploy
                    cp app.py python-app-deploy/
                '''
            }
        }

        stage('Run Application') {
            steps {
                echo "Running the Flask application..."
                sh '''
                    . venv/bin/activate
                    nohup python python-app-deploy/app.py > python-app-deploy/app.log 2>&1 &
                    echo $! > python-app-deploy/app.pid
                '''
            }
        }

        stage('Test Application') {
            steps {
                echo "Testing Application After Deploy..."
                sh '''
                    . venv/bin/activate
                    sleep 2
                    python -m unittest discover -s .
                '''
            }
        }

    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline FAILED — Check logs!"
        }
    }
}
