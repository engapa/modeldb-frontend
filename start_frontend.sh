#!/bin/bash -e

mkdir -p thrift

curl -Lo ModelDB.thrift https://raw.githubusercontent.com/mitdbg/modeldb/master/thrift/ModelDB.thrift

docker run -v $(pwd):/data thrift:0.10 \
        thrift -r -v -out /data/thrift --gen js:node /data/ModelDB.thrift

npm install
npm start