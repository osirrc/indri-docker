#!/usr/bin/env bash

COLLECTION_PATH=$1
INDEX=$2
COLLECTION_FORMAT=$3

#the mounted collection folder is read-only, for ROBUST04 we need a writable folder 
COLLECTION_PATH_WRITABLE=$1"-WRITABLE"

#if we are indexing ROBUST04, we need to unzip manually
if [ "$INDEX" = "robust04" ]; then
    echo "ROBUST04 ... Copying files of directory ${COLLECTION_PATH} into ${COLLECTION_PATH_WRITABLE}";
    
    #copy the whole corpus
    `cp -r ${COLLECTION_PATH} ${COLLECTION_PATH_WRITABLE}`

    #remove the unwanted parts of disk45 (as per ROBUST04 guidelines)
    `rm -r ${COLLECTION_PATH_WRITABLE}/disk4/cr`
    `rm -r ${COLLECTION_PATH_WRITABLE}/disk4/dtds`
    `rm -r ${COLLECTION_PATH_WRITABLE}/disk5/dtds`

    #ROBUST04 has a folder with `NAME.0z`, `NAME.1z` and `NAME.2z` files, simply using gunzip
    #is not an option as files are being overwritten (same name, different suffix)
    #hacked solution: add ".z" to every single file in the collection path
    find ${COLLECTION_PATH_WRITABLE} -name "*.0z" -type f -exec mv '{}' '{}'.z \;
    find ${COLLECTION_PATH_WRITABLE} -name "*.1z" -type f -exec mv '{}' '{}'.z \;
    find ${COLLECTION_PATH_WRITABLE} -name "*.2z" -type f -exec mv '{}' '{}'.z \;

    #uncompress
    echo "ROBUST04 ... Uncompressing";
    `gunzip -v --suffix=".z" -r ${COLLECTION_PATH_WRITABLE}`;
fi

#parameter file for indexing
touch index.param;
echo "<parameters>" >> index.param;
echo "<index>/work/${INDEX}</index>" >> index.param;
echo "<corpus>" >> index.param;
if [ "$INDEX" = "robust04" ]; then
    echo "<path>${COLLECTION_PATH_WRITABLE}</path>" >> index.param;
else
    echo "<path>${COLLECTION_PATH}</path>" >> index.param;
fi
echo "<class>${COLLECTION_FORMAT}</class>" >> index.param;
echo "</corpus>" >> index.param;
echo "</parameters>" >> index.param;

#show off the parameter file
more index.param

#start indexing
echo "Indexing ..."
/work/Indri/bin/IndriBuildIndex index.param