#!/usr/bin/env /bin/bash

docker login --username ${CONTAINER_REGISTRY_USERNAME} --password ${CONTAINER_REGISTRY_PASSWORD}

export INSTANCE_NAME="${NAME}-${VERSION}"

echo "name: ${NAME}"
echo "version: ${VERSION}"
echo "network: ${NETWORK}"
echo "instance: ${INSTANCE_NAME}"

docker pull ${CONTAINER_REGISTRY}/${NAME}:${VERSION}
docker run -d --rm --network=${NETWORK} --name ${INSTANCE_NAME} ${CONTAINER_REGISTRY}/${NAME}:${VERSION}
export IP_ADDRESS=$(docker inspect --format '{{ .NetworkSettings.Networks.frontend.IPAddress }}' ${INSTANCE_NAME})
echo "Ip address: ${IP_ADDRESS}"

# Register in LB
docker cp /deploy/conf.d/${NAME}.conf nginx:/etc/nginx/conf.d
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

