#!/usr/bin/env bash

# Setup variables.
COLLECTION_PATH=$1
INDEX=$2
#COLLECTION_FORMAT=$3

#parameter file for indexing
touch index.param;
echo "<parameters>\n" >> index.param;
echo "<corpus><path>" >> index.param;
echo ${COLLECTION_PATH} >> index.param;
echo "</path></corpus>\n" >> index.param;
echo "<class>trectext</class>\n" >> index.param;
echo "</corpus>\n" >> index.param;
echo "<index>" >> index.param;
echo ${INDEX} >> index.param;
echo "</index>\n" >> index.param;
echo "</parameters>" >> index.param;


`/work/Indri/bin/IndriBuildIndex index.param`
