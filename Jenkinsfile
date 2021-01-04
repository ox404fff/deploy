pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            dir '.'
            args '-v /var/run/docker.sock:/var/run/docker.sock -v $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent'
        }
    }
    parameters {
        string(name: 'application', description: 'Application')
        string(name: 'version', defaultValue: 'Hello', description: 'Version')
    }
    stages {
        stage('Test') {
            steps {
		sh '''
		    export APP_SERVER=142.93.96.209

                    mkdir ~/.ssh && ssh-keyscan -H ${APP_SERVER} >> ~/.ssh/known_hosts

                    ssh root@${APP_SERVER} -i ${SSH_APP_SERVERS} mkdir -p /tmp/.deployment/personal-${params.version}
                    sleep 15
                    scp -i ${SSH_APP_SERVERS} -r ./* root@${APP_SERVER}:/tmp/.deployment/personal-${params.version}
                    sleep 15
                    ssh root@${APP_SERVER} -i ${SSH_APP_SERVERS} docker build -t doctl -f /tmp/.deployment/personal-${params.version}/Dockerfile /tmp/.deployment/personal-${params.version}
                    sleep 15
                    ssh root@${APP_SERVER} -i ${SSH_APP_SERVERS} docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                        -e DIGITALOCEAN_ACCESS_TOKEN=${DIGITALOCEAN_ACCESS_TOKEN} \
                        -e BUILD_NUMBER=${BUILD_NUMBER} \
                        doctl /run/run.sh
                    sleep 15

		    ssh root@${APP_SERVER} -i ${SSH_APP_SERVERS} /bin/bash /run/reload.sh personal-${params.version}
                '''
            }
        }
    }
}
