pipeline {
    agent {
        dockerfile {
            filename 'Frontend/docker/Dockerfile'
            additionalBuildArgs '--target build'
            dir '.'
            args '-v /var/run/docker.sock:/var/run/docker.sock -v $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent'
        }
    }

    stages {
        stage('Test') {
            steps {
                sh "docker ps"
            }
        }
    }
}
