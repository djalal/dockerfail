set -e

REPO=$(basename $PWD)
REGISTRY=dockerfail
IMAGE_URI=dockerfail/$REPO:prod

#01/03 BUILD
docker run --rm -i hadolint/hadolint < Dockerfile
time docker build --progress=plain -t $IMAGE_URI .

#02/03 SHIP
docker push $IMAGE_URI 

#03/03 RUN
docker run --name $REPO -P -d --add-host=words:127.0.0.1 \
    --add-host=db:127.0.0.1 --workdir=/ \
    -e POSTGRES_PASSWORD=s3cr3t $IMAGE_URI

# inspect - docker images | grep 01
# dockerfail/01-hadolint                         prod                          d5814872c208   22 hours ago     1.2GB
# dive dockerfail/01-hadolint:prod
