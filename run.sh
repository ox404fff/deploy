#!/usr/bin/env /bin/bash

docker login --username ${CONTAINER_REGISTRY_USERNAME} --password ${CONTAINER_REGISTRY_PASSWORD}

export INSTANCE_NAME="${NAME}-${VERSION}"

echo "name: ${NAME}"
echo "version: ${VERSION}"
echo "network: ${NETWORK}"
echo "registry: ${CONTAINER_REGISTRY}"
echo "instance: ${INSTANCE_NAME}"

export IS_EXISTS=$(docker ps --format '{{.Names}}' | grep personal-283 | wc -l)
echo "Is exists: ${IS_EXISTS}"

docker pull ${CONTAINER_REGISTRY}/${NAME}:${VERSION}

if [ "$IS_EXISTS" == "1" ]; then
  echo "Stopping existsing container ${name}"
  docker stop ${INSTANCE_NAME}
fi

docker run -d --network=${NETWORK} --name ${INSTANCE_NAME} ${CONTAINER_REGISTRY}/${NAME}:${VERSION}
export IP_ADDRESS=$(docker inspect --format '{{ .NetworkSettings.Networks.frontend.IPAddress }}' ${INSTANCE_NAME})
export IS_WEB=$(docker inspect --format '{{ .NetworkSettings.Ports }}' ${INSTANCE_NAME} | grep "map\[80\/tcp:\[\]\]" | wc -l)
echo "Is web: ${IS_WEB}"
echo "Ip address: ${IP_ADDRESS}"

# Register in LB
if [ "$IS_WEB" == "1" ]; then
    echo "Registration in LB..."
    docker cp /deploy/conf.d/${NAME}.conf nginx:/etc/nginx/conf.d
    docker exec nginx sed -i "s/---IP_ADDRESS---/${IP_ADDRESS}/" /etc/nginx/conf.d/${NAME}.conf
    docker exec nginx nginx -s reload
fi

# Stop old containers
echo "Cleaning old containers..."
for name in $(docker ps --format '{{.Names}}' | grep ^${NAME}-[0-9]*$)
do
    if [[ "$name" != "${NAME}-${VERSION}" ]]
    then
        echo "Stopping container ${name}"
        docker stop ${name}
    fi
done

