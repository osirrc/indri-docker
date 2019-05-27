FROM ubuntu:18.04

#install basics

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    zlib1g-dev \
    python3

COPY index /
COPY init /
#COPY serch /

RUN ["chmod", "+x", "/init"]
RUN ["chmod", "+x", "/index"]
WORKDIR /work
CMD ["bash"]
