set -e

REPO=$(basename $PWD)
REGISTRY=dockerfail
IMAGE_URI=dockerfail/$REPO:prod

#01/03 BUILD
time docker build --progress=plain -t $IMAGE_URI .

#02/03 SHIP
docker push $IMAGE_URI 

#03/03 RUN
docker run --name $REPO -P -d --add-host=words:127.0.0.1 \
    --add-host=db:127.0.0.1 --workdir=/ \
    -e POSTGRES_PASSWORD=s3cr3t $IMAGE_URI

# inspect - docker images | grep 00
# dockerfail/00-base                             prod                          7d48436b8fa5   12 minutes ago   1.4GB
# dive dockerfail/00-base:prod
