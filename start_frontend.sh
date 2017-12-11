#!/bin/bash -e

mkdir -p './thrift'

docker run -v $(pwd)/..:/data thrift:0.10 \
        thrift -r -v -out /data/frontend/thrift --gen js:node /data/thrift/ModelDB.thrift

npm install
npm start