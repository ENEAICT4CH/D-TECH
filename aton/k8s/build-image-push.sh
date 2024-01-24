#!/bin/bash

set -e

GOOGLE_PROJECT_ID="enea-dtech"

IMAGE="eu.gcr.io/$GOOGLE_PROJECT_ID/enea-dtech-aton"
VERSION="1.0.2"
TAG="$IMAGE:$VERSION"

gcloud config set project $GOOGLE_PROJECT_ID

docker build -t $TAG -t "$IMAGE:latest" ../
docker push $TAG
docker push "$IMAGE:latest"
