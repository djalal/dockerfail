set -e

TAG=$(basename $PWD)
# Set up the REPO as var in your shell
IMAGE_URI=$REPO:$TAG
SECRET_NAME=$TAG-db.`date +%s`

#01/03 BUILD
docker run --rm -i hadolint/hadolint < Dockerfile
time docker build --progress=plain -t $IMAGE_URI .
docker run --platform=linux/amd64 --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src gcr.io/gcp-runtimes/container-structure-test test --image $IMAGE_URI --config /src/test.yaml
ggshield secret scan docker $IMAGE_URI
docker sbom $IMAGE_URI > sbom.txt

#02/03 SHIP
docker push $IMAGE_URI 

#03/03 RUN
docker swarm init || true
docker service rm $TAG || true

openssl rand -base64 32 | docker secret create $SECRET_NAME -
docker service create --secret=$SECRET_NAME --name $TAG --publish published=8060,target=80 --no-resolve-image --with-registry-auth  --host=words:127.0.0.1 --host=db:127.0.0.1 --env POSTGRES_PASSWORD_FILE=/run/secrets/$SECRET_NAME $IMAGE_URI
