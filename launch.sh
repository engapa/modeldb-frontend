#!/usr/bin/env bash

set -e

MDB_THRIFT_LOCAL=${MDB_THRIFT_LOCAL:-"false"}
MDB_THRIFT_GEN=${MDB_THRIFT_GEN:-"true"}
MDB_THRIFT_VERSION=${MDB_THRIFT_VERSION:-"0.10.0"}
MDB_THRIFT_MODEL_VERSION=${MDB_THRIFT_MODEL_VERSION:-"master"}
MDB_WAIT_BACKEND=${MDB_WAIT_BACKEND:-"true"}
MDB_BACKEND_HOST=${MDB_BACKEND_HOST:-"localhost"}

function gen() {

  curl -Lo ModelDB.thrift https://raw.githubusercontent.com/mitdbg/modeldb/${MDB_THRIFT_MODEL_VERSION}/thrift/ModelDB.thrift

  if [[ "${MDB_THRIFT_GEN}" == "true" ]]; then
    mkdir -p thrift
    if [[ "$MDB_THRIFT_LOCAL" == 'true' ]]; then
      if [[ ! "$(thrift -version)" ]]; then
        pushd ~/
        wget -q http://archive.apache.org/dist/thrift/${MDB_THRIFT_VERSION}/thrift-${MDB_THRIFT_VERSION}.tar.gz
        tar -xzf thrift-${MDB_THRIFT_VERSION}.tar.gz
        cd thrift-${MDB_THRIFT_VERSION} && ./configure --without-python && make
        ln -n ~/thrift-${MDB_THRIFT_VERSION}/compiler/cpp/thrift /usr/local/bin/thrift
        popd
        thrift -version
      fi
      thrift -r -out 'thrift' -gen js:node 'ModelDB.thrift'
    else
      docker run -v $(pwd):/data thrift:${MDB_THRIFT_VERSION} \
        thrift -r -v -out /data/thrift --gen js:node /data/ModelDB.thrift
    fi
  fi

}

function start() {

  npm install

  node_param=""
  npm_param=""

  if [ -n "$MDB_BACKEND_HOST" ]; then
    node_param="--host $MDB_BACKEND_HOST"
    npm_param="-- $node_param"
  fi

  if [[ "$MDB_WAIT_BACKEND" == 'true' ]]; then
    until node util/check_thrift.js $node_param > /dev/null 2>&1; do
      >&2 echo "Backend is unavailable - sleeping"
      sleep 1
    done
    >&2 echo "Backend is up - executing command"
  fi
  exec npm start $npm_param
}


function stop() {

  npm stop

}

# Main options
case "$1" in
  gen)
        shift
        gen
        ;;
  start)
        shift
        start
        ;;
  stop)
        stop
        exit $?
        ;;
  *)
        echo "Usage: $0 {gen|start|stop}"
        exit 1
esac