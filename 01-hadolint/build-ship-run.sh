set -e

TAG=$(basename $PWD)
# Set up the REPO as var in your shell
IMAGE_URI=$REPO:$TAG

#01/03 BUILD
echo "hadooolint"
docker run --rm -i hadolint/hadolint < Dockerfile 
time docker build --progress=plain -t $IMAGE_URI .

#02/03 SHIP
docker push $IMAGE_URI 

#03/03 RUN
docker run --name $TAG -P -d --add-host=words:127.0.0.1 --add-host=db:127.0.0.1 --workdir=/ -e POSTGRES_PASSWORD=s3cr3t $IMAGE_URI
