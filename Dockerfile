from yikaus/alpine-bash

# RUN apt-get update && apt-get install -y \
#    curl

copy . /root/workdir/
ENV PATH "$PATH:/root/workdir"
workdir /root/workdir
entrypoint /bin/sh
