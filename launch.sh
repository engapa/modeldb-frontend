#!/usr/bin/env bash

set -e

MDB_THRIFT_LOCAL=${MDB_THRIFT_LOCAL:-"false"}
MDB_THRIFT_VERSION=${MDB_THRIFT_VERSION:-"0.10.0"}
MDB_THRIFT_MODEL_VERSION=${MDB_THRIFT_MODEL_VERSION:-"master"}
MDB_WAIT_BACKEND=${MDB_WAIT_BACKEND:-"true"}
MDB_BACKEND_HOST=${MDB_BACKEND_HOST:-"localhost"}

MDB_DOCKER_NAME=${MDB_DOCKER_NAME:-"modeldb-frontend"}
MDB_DOCKER_NAME_TAG=${MDB_DOCKER_NAME_TAG:-"latest"}
MDB_DOCKER_OPTS=${MDB_DOCKER_OPTS:-"-it --net=host"}

function gen() {

  curl -Lo ModelDB.thrift https://raw.githubusercontent.com/mitdbg/modeldb/${MDB_THRIFT_MODEL_VERSION}/thrift/ModelDB.thrift

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
    docker run --rm -v $(pwd):/data thrift:${MDB_THRIFT_VERSION} \
      thrift -r -v -out /data/thrift --gen js:node /data/ModelDB.thrift
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

function docker-build() {

  docker build -t modeldb-frontend:latest \
    --label modeldb=frontend \
    --build-arg MDB_THRIFT_LOCAL=$MDB_THRIFT_LOCAL \
    --build-arg MDB_THRIFT_VERSION=$MDB_THRIFT_VERSION \
    --build-arg MDB_THRIFT_MODEL_VERSION=$MDB_THRIFT_MODEL_VERSION .

}

function docker-start() {

    [[ $(docker ps -a -f "name=$MDB_DOCKER_NAME" --format '{{.Names}}') == $MDB_DOCKER_NAME ]] && \
       (echo "Container $MDB_DOCKER_NAME already exists"; exit 1)

    MDB_DOCKER_OPTS="${MDB_DOCKER_OPTS} -e MDB_WAIT_BACKEND=${MDB_WAIT_BACKEND} -e MDB_BACKEND_HOST=${MDB_BACKEND_HOST} "

    if [[ "${MDB_THRIFT_LOCAL}" == 'false' ]]; then
       MDB_DOCKER_OPTS="${MDB_DOCKER_OPTS} -v $(pwd)/thrift "
    fi

    docker run $MDB_DOCKER_OPTS --name $MDB_DOCKER_NAME $MDB_DOCKER_NAME:$MDB_DOCKER_NAME_TAG

}

function docker-stop() {

    [[ $(docker ps -f "name=$MDB_DOCKER_NAME" --format '{{.Names}}') == $MDB_DOCKER_NAME ]] && \
       docker stop $MDB_DOCKER_NAME

}

function clean-all() {

    [ -d thrift ] && rm -r ./thrift

    [[ $(docker ps -a -f "name=$MDB_DOCKER_NAME" --format '{{.Names}}') == $MDB_DOCKER_NAME ]] && \
       docker rm -f $MDB_DOCKER_NAME

    IMAGES_TO_DEL=$(docker images -f label="modeldb=frontend" --format '{{.ID}}')
    if [[ $IMAGES_TO_DEL ]]; then docker rmi $IMAGES_TO_DEL; fi

}

# Main options
case "$1" in
  gen)
        gen
        ;;
  start)
        start
        ;;
  stop)
        stop
        exit $?
        ;;
  docker-build)
        docker-build
        ;;
  docker-start)
        docker-start
        ;;
  docker-stop)
        docker-start
        ;;
  clean-all)
        clean-all
        ;;
  *)
        echo "Usage: $0 {gen|start|docker-build|docker-start|stop|docker-stop|clean-all}"
        exit 1
esac