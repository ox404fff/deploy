#!/usr/bin/env /bin/bash

doctl auth init && doctl registry login

export INSTANCE_NAME="${NAME}-${VERSION}"

echo "name: ${NAME}"
echo "version: ${VERSION}"
echo "network: ${NETWORK}"
echo "path: ${WORKSPACE_PATH}"
echo "instance: ${INSTANCE_NAME}"

docker pull registry.digitalocean.com/oz9aud6dhsxd/personal:latest
docker run -d --rm --network=${NETWORK} --name ${INSTANCE_NAME} registry.digitalocean.com/oz9aud6dhsxd/personal:latest
export IP_ADDRESS=$(docker inspect --format '{{ .NetworkSettings.Networks.frontend.IPAddress }}' ${INSTANCE_NAME})
echo "Ip address: ${IP_ADDRESS}"

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

