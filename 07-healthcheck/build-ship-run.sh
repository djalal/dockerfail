set -e

source ../.env

TIMESTAMP=`date +%s`
REPO=$(basename $PWD)
REGISTRY=dockerfail
IMAGE_URI=$REGISTRY/$REPO:$TIMESTAMP
SECRET_NAME=$REPO-db.$TIMESTAMP

#01/03 BUILD
docker run --rm -i hadolint/hadolint < Dockerfile
time docker build --progress=plain -t $IMAGE_URI .
docker run --platform=linux/amd64 --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD:/src gcr.io/gcp-runtimes/container-structure-test \
    test --image $IMAGE_URI --config /src/test.yaml
ggshield secret scan docker $IMAGE_URI

mkdir -p ../data/$REPO
docker sbom $IMAGE_URI > ../data/$REPO/sbom.txt

#02/03 SHIP
docker push $IMAGE_URI 

#03/03 RUN
docker swarm init || true
docker service rm $REPO || true

openssl rand -base64 32 | docker secret create $SECRET_NAME -
docker service create --secret=$SECRET_NAME --name $REPO \
    --publish published=8070,target=80 --no-resolve-image --with-registry-auth \
    --host=words:127.0.0.1 --host=db:127.0.0.1 \
    --env POSTGRES_PASSWORD_FILE=/run/secrets/$SECRET_NAME $IMAGE_URI
