#!/usr/bin/env bash

COLLECTION_PATH=$1
INDEX="/"$2
COLLECTION_FORMAT=$3
COLLECTION_PATH_WRITABLE=$1"-WRITABLE"

mkdir ${COLLECTION_PATH_WRITABLE}

#first we need to parse the collection
cd /
npm install sanitize-html
nodejs /parseCore18.js ${COLLECTION_PATH}/data/* ${COLLECTION_PATH_WRITABLE}

#retrieve stopword list (stored in current directory)
wget http://www.lemurproject.org/stopwords/stoplist.dft
echo "Retrieved stopword list"

#create the parameter file for indexing
touch index.param
echo "<parameters>" >> index.param
echo "<index>${INDEX}</index>" >> index.param
echo "<stemmer><name>krovetz</name></stemmer>" >> index.param
echo "<corpus>" >> index.param
echo "<path>${COLLECTION_PATH_WRITABLE}</path>" >> index.param
echo "<class>${COLLECTION_FORMAT}</class>" >> index.param
echo "</corpus>" >> index.param
echo "</parameters>" >> index.param

#printout
more index.param

#start indexing
echo "Core18 ... Indexing"
/work/Indri/bin/IndriBuildIndex index.param stoplist.dft

ls /core18
ls /core18/index
more /core18/index/0/manifest
more /core18/index/1/manifest
more /core18/index/2/manifest
more /core18/index/3/manifest
more /core18/index/4/manifest
more /core18/index/5/manifest
more /core18/index/6/manifest
