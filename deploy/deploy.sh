#!/bin/bash

GREEN='\033[1;32m'
SMILE='\xE2\x98\xBB'
NC='\033[0m'

if [ -z "$1" ]
    then
        echo "Release not provided"
        exit
fi

. .deploy

export STACK_NAME=$STACK_NAME
export BUCKET_NAME=$BUCKET_NAME 

mkdir -p dist/${1}/src

echo "Copying template to S3 bucket"
aws s3 cp donkeys.yaml s3://$BUCKET_NAME/${1}/donkeys.yaml
cp donkeys.yaml dist/$1/donkeys.yaml

echo "Copying Parameters to S3 bucket"
aws s3 cp parameters/parameters.json s3://$BUCKET_NAME/${1}/parameters.json
cp parameters/parameters.json dist/$1/parameters.json

#Prepare Lambda
rm -rf dist/${1}/src/*
./bin/install-and-prune.sh $1 /

printf "\n ${GREEN}${SMILE} All functions packaged!${NC}\n\n"

#Copy Lambdas
aws s3 cp --recursive --exclude "*.DS*" dist/${1}/src s3://${BUCKET_NAME}/${1}/lambda-src/

echo "Deploying stack ${STACK_NAME}"
./bin/deploy/deploy-stack.sh $1

read -p "Check the AWS console for build status.  Press any key to continue."