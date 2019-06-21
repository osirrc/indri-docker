#!/usr/bin/env bash

COLLECTION_PATH=$1
INDEX="/"$2
COLLECTION_FORMAT=$3
COLLECTION_PATH_WRITABLE=$1"-WRITABLE"

#first we need to parse the collection
nodejs /parseCore18.js ${COLLECTION_PATH}/data/* ${COLLECTION_PATH_WRITABLE}

#retrieve stopword list (stored in current directory)
wget http://www.lemurproject.org/stopwords/stoplist.dft

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

#printout manifest file (manifest file path assumes entire collectionn is indexed)
more ${INDEX}/index/1/manifest
more ${INDEX}/index/2/manifest

