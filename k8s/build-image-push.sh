#!/bin/bash

set -e

GOOGLE_PROJECT_ID="enea-dtech"

IMAGE="eu.gcr.io/$GOOGLE_PROJECT_ID/enea-dtech-nginx"
VERSION="1.1.0"
TAG="$IMAGE:$VERSION"

gcloud config set project $GOOGLE_PROJECT_ID

docker build -t $TAG -t "$IMAGE:latest" ./nginx/
docker push $TAG
docker push "$IMAGE:latest"
