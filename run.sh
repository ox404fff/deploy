#!/usr/bin/env /bin/bash

export INSTANCE_NAME=$1
export VERSION=""
export NAME=""

export IP_ADDRESS=$(docker inspect --format '{{ .NetworkSettings.Networks.frontend.IPAddress }}' ${INSTANCE_NAME})

echo $IP_ADDRESS

# Parse:
for i in ${INSTANCE_NAME//-/ }
do
    VERSION=$i
    [[ -z "${NAME// }" ]] && NAME=$i || NAME="${NAME}-$i"
done

NAME=${NAME%"-$VERSION"}

# Register in LB
docker cp /var/www/nginx/conf/${NAME}.conf nginx:/etc/nginx/conf.d
docker exec nginx sed -i "s/---IP_ADDRESS---/${IP_ADDRESS}/" /etc/nginx/conf.d/${APP_NAME}.conf
docker exec nginx nginx -s reload


# Stop old containers
for name in $(docker ps --format '{{.Names}}' | grep ^${NAME}-[0-9]*$)
do
    if [[ "$name" != "${NAME}-${VERSION}" ]]
    then
        docker stop ${name}
    fi
done

