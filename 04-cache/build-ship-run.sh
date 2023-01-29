set -e

REPO=$(basename $PWD)
REGISTRY=dockerfail
IMAGE_URI=dockerfail/$REPO:prod

#01/03 BUILD
docker run --rm -i hadolint/hadolint < Dockerfile
time docker build --progress=plain -t $IMAGE_URI .
docker run --platform=linux/amd64 --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD:/src gcr.io/gcp-runtimes/container-structure-test \
    test --image $IMAGE_URI --config /src/test.yaml

#02/03 SHIP
docker push $IMAGE_URI 

#03/03 RUN
docker run --name $REPO -P -d --add-host=words:127.0.0.1 \
    --add-host=db:127.0.0.1 \
    --workdir=/ -e POSTGRES_PASSWORD=s3cr3t $IMAGE_URI

# inspect - docker images | grep 04
# dockerfail/04-cache                            prod                          b068c2e97ecf   3 days ago       616MB
# dive dockerfail/04-cache:prod
