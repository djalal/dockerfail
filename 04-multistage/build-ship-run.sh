set -e

REPO=$(basename $PWD)
REGISTRY=maboullaite857
IMAGE_URI=maboullaite857/$REPO:prod

#01/03 BUILD
docker run --rm -i hadolint/hadolint < Dockerfile
time docker build --progress=plain -t $IMAGE_URI .
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD:/src gcr.io/gcp-runtimes/container-structure-test \
    test --image $IMAGE_URI --config /src/test.yaml

#02/03 SHIP
docker push $IMAGE_URI 

#03/03 RUN
docker run --name $REPO -P -d --add-host=words:127.0.0.1 \
    --add-host=db:127.0.0.1 \
    --workdir=/ -e POSTGRES_PASSWORD=s3cr3t $IMAGE_URI

# inspect - docker images | grep 03
# dockerfail/03-multistage                       prod                          45c522febe72   3 days ago       616MB
# dive dockerfail/03-multistage:prod
