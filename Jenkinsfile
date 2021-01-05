pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            dir '.'
            args '-v /var/run/docker.sock:/var/run/docker.sock -v $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent'
        }
    }
    parameters {
        string(name: 'APP_NAME', defaultValue: '', description: 'Application')
        string(name: 'APP_VERSION', defaultValue: '', description: 'Version')
    }
    stages {
        stage('Test') {
            steps {
		withCredentials([
                    string(credentialsId: 'doAccessToken', variable: 'DIGITALOCEAN_ACCESS_TOKEN'),
                    sshUserPrivateKey(credentialsId: 'app-servers', keyFileVariable: 'SSH_APP_SERVERS')
                ]) {
		    sh '''
		        export APP_SERVER=142.93.96.209

		        export WORKSPACE_PATH="/tmp/.deployment/${APP_NAME}-${APP_VERSION}"

                        mkdir ~/.ssh && ssh-keyscan -H ${APP_SERVER} >> ~/.ssh/known_hosts

                        ssh root@${APP_SERVER} -i ${SSH_APP_SERVERS} mkdir -p ${WORKSPACE_PATH}
                        sleep 15
                        scp -i ${SSH_APP_SERVERS} -r ./* root@${APP_SERVER}:${WORKSPACE_PATH}
                        sleep 15
		        ssh root@${APP_SERVER} -i ${SSH_APP_SERVERS} /bin/bash ${WORKSPACE_PATH}/run.sh "${APP_NAME}" "${APP_VERSION}" "${WORKSPACE_PATH}" "${DIGITALOCEAN_ACCESS_TOKEN}"
                    '''
                }
            }
        }
    }
}
