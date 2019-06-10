#!/usr/bin/env bash

COLLECTION_PATH=$1
INDEX=$2
COLLECTION_FORMAT=$3

#parameter file for indexing
touch index.param;
echo "<parameters>" >> index.param;
echo "<index>/${INDEX}</index>" >> index.param;
echo "<corpus>" >> index.param;
echo "<path>${COLLECTION_PATH}</path>" >> index.param;
echo "<class>${COLLECTION_FORMAT}</class>" >> index.param;
echo "</corpus>" >> index.param;
echo "</parameters>" >> index.param;

more index.param
/work/Indri/bin/IndriBuildIndex index.param

#ls -al /robust/index/1/
#more /robust/index/1/manifest