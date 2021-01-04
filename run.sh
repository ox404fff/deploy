#!/usr/bin/env /bin/bash

export NAME=$1
export VERSION=$2
export INSTANCE_NAME="${NAME}-${VERSION}"

export IP_ADDRESS=$(docker inspect --format '{{ .NetworkSettings.Networks.frontend.IPAddress }}' ${INSTANCE_NAME})

docker build -t doctl -f ${WORKSPACE_PATH}/Dockerfile ${WORKSPACE_PATH}
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
	-e DIGITALOCEAN_ACCESS_TOKEN=${DIGITALOCEAN_ACCESS_TOKEN} \
        -e APP_NAME=${APP_NAME} \
        -e APP_VERSION=${APP_VERSION} \
        doctl /run/run.sh 

echo "Ip address of new instance: ${IP_ADDRESS}"

# Register in LB
docker cp ${WORKSPACE_PATH}/conf.d/${NAME}.conf nginx:/etc/nginx/conf.d
docker exec nginx sed -i "s/---IP_ADDRESS---/${IP_ADDRESS}/" /etc/nginx/conf.d/${NAME}.conf
docker exec nginx nginx -s reload


# Stop old containers
for name in $(docker ps --format '{{.Names}}' | grep ^${NAME}-[0-9]*$)
do
    if [[ "$name" != "${NAME}-${VERSION}" ]]
    then
        docker stop ${name}
    fi
done

