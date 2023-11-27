#!/bin/bash

CURRENT_DIR=$(basename `pwd`)
if [ ! "${CURRENT_DIR}" = "composable-rss-app" ]
then
	echo "Wrong dir: ${CURRENT_DIR}";
	exit;
fi
echo "Current dir: ${CURRENT_DIR}"

# change to the client dir
cd composable-rss-client

# install dependencies
npm install 

# build the artifacts via gradle
npm run build

# build the docker image with the updated artifacts
docker build \
  -t lostsidewalk/composable-rss-client:latest \
  .

# return to parent dir (newsgears-app)
cd ..
