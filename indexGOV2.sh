#!/usr/bin/env bash

COLLECTION_PATH=$1
INDEX="/"$2
COLLECTION_FORMAT=$3

#retrieve stopword list (stored in current directory)
wget http://www.lemurproject.org/stopwords/stoplist.dft

#create the parameter file for indexing
touch index.param
echo "<parameters>" >> index.param
echo "<index>${INDEX}</index>" >> index.param
echo "<stemmer><name>krovetz</name></stemmer>" >> index.param
echo "<corpus>" >> index.param
echo "<path>${COLLECTION_PATH}</path>" >> index.param
echo "<class>${COLLECTION_FORMAT}</class>" >> index.param
echo "</corpus>" >> index.param
echo "</parameters>" >> index.param

#printout
more index.param

#start indexing
echo "GOV2 ... Indexing"
/work/Indri/bin/IndriBuildIndex index.param stoplist.dft

#printout manifest file
more ${INDEX}/index/1/manifest
more ${INDEX}/index/2/manifest
more ${INDEX}/index/3/manifest
more ${INDEX}/index/4/manifest
more ${INDEX}/index/5/manifest
more ${INDEX}/index/6/manifest
more ${INDEX}/index/7/manifest
more ${INDEX}/index/8/manifest
more ${INDEX}/index/9/manifest
more ${INDEX}/index/10/manifest
more ${INDEX}/index/11/manifest
more ${INDEX}/index/12/manifest
more ${INDEX}/index/13/manifest
more ${INDEX}/index/14/manifest
