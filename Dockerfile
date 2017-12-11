FROM node:latest

EXPOSE 3000

ENV MDB_THRIFT_LOCAL="true" \
    MDB_THRIFT_GEN="true" \
    MDB_THRIFT_VERSION="0.10.0" \
    MDB_THRIFT_MODEL_VERSION="master" \
    MDB_WAIT_BACKEND="true" \
    MDB_BACKEND_HOST="localhost"

RUN apt-get update \
    && apt-get install -y \
        g++ \
        make \
        wget \
    && apt-get clean

WORKDIR /root

ADD . /modeldb-frontend

WORKDIR /modeldb-frontend

# Install Thrift and generate thrift code
RUN ./launch.sh gen

ENTRYPOINT ["/modeldb-frontend/launch.sh"]
CMD ["start"]