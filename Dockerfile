FROM ubuntu:18.04

#install basics
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    g++ \
    make \
    zlib1g-dev \
    python3

COPY . /

WORKDIR /work
RUN chmod +x /init
RUN chmod +x /index
#COPY search /

#RUN ["chmod", "+x", "/init"]
#RUN ["chmod", "+x", "/index"]
