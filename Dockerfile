FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    g++ \
    make \
    zlib1g-dev \
    python3

WORKDIR /work

#download, configure and install Indri
RUN wget --no-check-certificate https://sourceforge.net/projects/lemur/files/lemur/indri-5.13/indri-5.13.tar.gz
RUN tar -xvzf indri-5.13.tar.gz -C /work
RUN /work/indri-5.13/configure --prefix=/work/Indri
RUN cd /work/indri-5.13 && cp ../Make* . && make && make install

COPY index /
COPY indexRobust04.sh /
COPY indexGOV2.sh /
COPY indexCore18.sh /
COPY search /
COPY search.sh /
COPY topicFormatting.pl /

RUN chmod +x /index
RUN chmod +x /search