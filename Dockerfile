FROM ubuntu:14.04

#install a few essentials
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    g++ \
    make \
    zlib1g-dev \
    python3

WORKDIR /work

#download, configure and install Indri
RUN wget --no-check-certificate https://sourceforge.net/projects/lemur/files/lemur/indri-5.11/indri-5.11.tar.gz
RUN tar -xvzf indri-5.11.tar.gz -C /work
RUN /work/indri-5.11/configure --prefix=/work/Indri
RUN cd /work/indri-5.11 && cp ../Make* . && make && make install

COPY index /index
COPY index.sh /index.sh

RUN chmod +x /index
RUN chmod +x /index.sh

#COPY search /