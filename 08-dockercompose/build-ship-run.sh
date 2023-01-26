set -e

TIMESTAMP=`date +%s`
TAG=$(basename $PWD)
# Set up the REPO as var in your shell
IMAGE_URI=$REPO
SECRET_NAME=$TAG-db.$TIMESTAMP
OLDPWD=$PWD

#01/03 BUILD
for SERVICE in web words db; do
    cd $SERVICE
    docker run --rm -i hadolint/hadolint < Dockerfile
    cd $OLDPWD
done

# 24 secs vs 1m14.033s build time!
#time docker build --progress=plain -t dockerfail:$TAG .
time env IMAGE_URI=$IMAGE_URI TAG=$TAG-$TIMESTAMP docker compose build

for SERVICE in web words db; do
    cd $SERVICE
    echo inspecting $IMAGE_URI:$SERVICE-$TAG-$TIMESTAMP
    docker run --platform=linux/amd64 --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src gcr.io/gcp-runtimes/container-structure-test test --image $IMAGE_URI:$SERVICE-$TAG-$TIMESTAMP --config /src/test.yaml
    ggshield secret scan docker $IMAGE_URI:$SERVICE-$TAG-$TIMESTAMP
    docker sbom $IMAGE_URI:$SERVICE-$TAG-$TIMESTAMP > $OLDPWD/sbom-$SERVICE.txt
    cd $OLDPWD
done

#02/03 SHIP
time IMAGE_URI=$IMAGE_URI TAG=$TAG-$TIMESTAMP docker compose push

#03/03 RUN
docker swarm init || true
docker stack rm $TAG || true

openssl rand -base64 32 | md5 | docker secret create $SECRET_NAME -

echo IMAGE_URI=$IMAGE_URI TAG=$SERVICE-$TAG-$TIMESTAMP SECRET_NAME=$SECRET_NAME STACK=dockerfail
IMAGE_URI=$IMAGE_URI TAG=$TAG-$TIMESTAMP SECRET_NAME=$SECRET_NAME docker stack deploy --with-registry-auth --compose-file docker-compose.yaml --compose-file docker-compose.prod.yaml dockerfail
