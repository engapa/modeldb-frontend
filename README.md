[![Build Status](https://travis-ci.org/engapa/modeldb-frontend.svg)](https://travis-ci.org/engapa/modeldb-frontend)
[![Docker Pulls](https://img.shields.io/docker/pulls/engapa/modeldb-frontend.svg)](https://hub.docker.com/r/engapa/modeldb-frontend/)
[![Docker Stars](https://img.shields.io/docker/stars/engapa/modeldb-frontend.svg)](https://hub.docker.com/r/engapa/modeldb-frontend/)

# modeldb-frontend

## Intro

A basic fork of official frontend module of [ModelDB machine learning management system](http://modeldb.csail.mit.edu).

Visit the original project at:  https://github.com/mitdbg/modeldb

This project goal is to try to add some additional features:

- [x] [Confusion Matrix(https://www.google.es/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwjr9YCtuqzYAhWEShQKHdvzDOoQFggnMAA&url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FConfusion_matrix&usg=AOvVaw1sC8cquKC7ZuBe4qQXFbe5)]
- [x] Compute resources consumption
- [ ] OAuth integration

## Setup and run

By using the script `launch.sh` you will can launc almost all operations (type `./launch.sh help` or see contents of the file).
Besides, there are some variables to setup the script (all of them with **MDB_** prefix):

NAME                    | DESCRIPTION                 |         Example
------------------------|-----------------------------|-----------------------------
MDB_THRIFT_LOCAL        | Execute thrift from distribuition (defaults to *true*) or use a docker container (false)
MDB_THRIFT_VERSION      | Thrift version (defaults to *0.10.0*)
MDB_THRIFT_MODEL_VERSION| Version of the ModelDB.thrift file (defaults to *master*)
MDB_WAIT_BACKEND        | Wait backend be reachable (defaults to *true*)
MDB_BACKEND_HOST        | Set backend host (defaults to *localhost*)
MDB_DOCKER_NAME         | Docker container name (defaults to *modeldb-frontend*)
MDB_DOCKER_NAME_TAG     | Docker tag for container (defaults to *latest*)
MDB_DOCKER_OPTS         | Default docker options (defaults to `-d --net=host)

First of all make sure that the ModelDB server (backend) is running and adjust the **MDB_BACKEND_HOST** variable.

Here you have a couple of examples about how to run it:

- Running on localhost, generating thrift sources by a docker container (by default) previously:

```sh
$ MDB_THRIFT_LOCAL=false ./launch.sh gen
$ ./launch.sh start
```

- Running on localhost through a docker container:
```sh
$ ./launch.sh docker-build
$ ./launch.sh docker-start
```
>NOTE: Generate sources of thrift are passed as volume to the containers (directory thrift create in the above example).
 If you want to generate the thrift sources within the same container then provide **MDB_THRIFT_LOCAL="true"** with the docker-build operation

In order to purge all created resources above enter this command `./launch.sh clean-all` (included docker containers and images)

After all, the frontend should be available at http://localhost:3000
