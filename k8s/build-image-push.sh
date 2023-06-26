#!/bin/bash

set -e

GOOGLE_PROJECT_ID="enea-dtech"

TAG="eu.gcr.io/$GOOGLE_PROJECT_ID/enea-dtech-nginx"

gcloud config set project $GOOGLE_PROJECT_ID

docker build -t $TAG ./nginx/

docker push $TAG
