pipeline {
    agent any

    tools {
        nodejs 'node20'  // Predefined Node.js tool installation
    }

    environment {
        APP_NAME = "crud-be-devops"
        RELEASE = "latest"
        IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    }

    stages {
        stage("Checkout from SCM") {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/ahadalichowdhury/crud-be-devops'
            }
        }
stage('SonarQube Analysis') {
    steps {
        script {
            // Set the SCANNER_HOME variable
            env.SCANNER_HOME = tool 'sonar-scanner'  // Ensure this matches your tool configuration
            
            withSonarQubeEnv('sonar-server') {
                // Echo SCANNER_HOME for debugging purposes
                echo "SCANNER_HOME: ${env.SCANNER_HOME}"

                // Run the SonarScanner using double quotes
                sh """
                ${env.SCANNER_HOME}/bin/sonar-scanner \
                -Dsonar.projectKey=backend \
                -Dsonar.sources=. \
                -Dsonar.host.url=http://54.146.88.139:9000 \
                -Dsonar.login=squ_81982f421457e0e6d324b31a9dadc4304a267ae8
                """
            }
        }
    }
}
	     stage("Quality Gate"){
           steps {
               script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }	
            }

        }





        stage('Install Node.js Dependencies') {
            steps {
                script {
                    // Install Node.js dependencies
                    sh 'npm install'
                }
            }
        }

        stage('Build Docker') {
            steps {
                script {
                    // Use withCredentials to access the secret
                    withCredentials([string(credentialsId: 'MONGODB_URI', variable: 'MONGODB_URI')]) {
                        sh """
                        echo 'Building Docker Image with secret'
                        docker build --build-arg MONGODB_URI=${MONGODB_URI} -t ahadalichowdhury/crud-be-devops:${BUILD_NUMBER} .
                        """
                    }
                }
            }
        }



        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                        echo 'Logging into Docker Hub'
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        '''
                    }
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    sh '''
                    echo 'Pushing to Docker Hub'
                    docker push ahadalichowdhury/crud-be-devops:${BUILD_NUMBER}
                    '''
                }
            }
        }
        stage("TRIVY Image Scan") {
            steps {
                sh 'trivy image ahadalichowdhury/crud-be-devops:${BUILD_NUMBER} > trivyimage.txt' 
            }
        }

        stage('Update Helm Chart and Push to GitHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                        sh """
                            # Update tag in the Helm chart file
                            sed -i 's/tag: .*/tag: ${BUILD_ID}/' helm/crud-be/values.yaml
                            
                            # Configure Git with user information
                            git config user.email "smahadalichowdhury@gmail.com"
                            git config user.name "ahadalichowdhury"
                            
                            # Add and commit the changes
                            git add helm/crud-be/values.yaml
                            git commit -m "Update tag in Helm chart"
                            
                            # Push to the GitHub repository using the Personal Access Token (PAT)
                            git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/ahadalichowdhury/crud-be-devops main
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}