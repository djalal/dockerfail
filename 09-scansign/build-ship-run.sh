set -e

# init env vars with secrets
source ../.env

TIMESTAMP=`date +%s`
REPO=$(basename $PWD)
REGISTRY=dockerfail
IMAGE_URI=$REGISTRY/$REPO
SECRET_NAME=$REPO-db.$TIMESTAMP
OLDPWD=$PWD

#01/03 BUILD
for SERVICE in web words db; do
    cd $SERVICE
    docker run --rm -i hadolint/hadolint < Dockerfile
    cd $OLDPWD
done

# 24 secs vs 1m14.033s build time!
#time docker build --progress=plain -t dockerfail:$TAG .
time env IMAGE_URI=$IMAGE_URI TAG=$TIMESTAMP docker compose build

for SERVICE in web words db; do
    cd $SERVICE
    echo inspecting $IMAGE_URI-$SERVICE:$TIMESTAMP
    docker run --platform=linux/amd64 --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src gcr.io/gcp-runtimes/container-structure-test test --image $IMAGE_URI-$SERVICE:$TIMESTAMP --config /src/test.yaml
    ggshield secret scan docker $IMAGE_URI-$SERVICE:$TIMESTAMP
    mkdir -p $OLDPWD/../data/$REPO
    docker sbom $IMAGE_URI-$SERVICE:$TIMESTAMP > $OLDPWD/../data/$REPO/sbom-$SERVICE.txt
    cd $OLDPWD
done

#02/03 SHIP
export DOCKER_CONTENT_TRUST=1

# docker compose does not support DCT pushes yet
for SERVICE in web words db; do
    docker push $IMAGE_URI-$SERVICE:$TIMESTAMP
done

#03/03 RUN
for SERVICE in web words db; do
    docker pull $IMAGE_URI-$SERVICE:$TIMESTAMP
    docker trust inspect $IMAGE_URI-$SERVICE:$TIMESTAMP
done

docker swarm init || true
docker stack rm $REPO || true

openssl rand -base64 32 | md5 | docker secret create $SECRET_NAME -

echo IMAGE_URI=$IMAGE_URI TAG=$TIMESTAMP SECRET_NAME=$SECRET_NAME REPO=$REPO
IMAGE_URI=$IMAGE_URI TAG=$TIMESTAMP SECRET_NAME=$SECRET_NAME docker stack deploy --with-registry-auth --compose-file docker-compose.yaml --compose-file docker-compose.prod.yaml $REPO

export DOCKER_CONTENT_TRUST=0
