FROM node:latest

EXPOSE 3000

ARG MDB_THRIFT_LOCAL="true"
ARG MDB_THRIFT_VERSION="0.10.0"
ARG MDB_THRIFT_MODEL_VERSION="master"

ENV MDB_WAIT_BACKEND="true"
ENV MDB_BACKEND_HOST="localhost"

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
RUN if [ "${MDB_THRIFT_LOCAL}" = "true" ]; then ./launch.sh gen; fi

ENTRYPOINT ["/modeldb-frontend/launch.sh"]
CMD ["start"]