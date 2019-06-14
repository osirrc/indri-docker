#!/usr/bin/env bash

#Robust04 is an old collection, compressed in a format that Indri does not understand.
#Requires unzipping of the collection.
#A number of folders are then deleted (part of TREC Vol. 4+5 but not part of the Robust04).

COLLECTION_PATH=$1
INDEX="/"$2
COLLECTION_FORMAT=$3

#the mounted collection folder is read-only, we need a writable folder 
COLLECTION_PATH_WRITABLE=$1"-WRITABLE"

echo "ROBUST04 ... Copying files of directory ${COLLECTION_PATH} into ${COLLECTION_PATH_WRITABLE}"
  
#copy the whole corpus
cp -r ${COLLECTION_PATH} ${COLLECTION_PATH_WRITABLE}

#remove the unwanted parts of disk45 (as per ROBUST04 guidelines)
rm -r ${COLLECTION_PATH_WRITABLE}/disk4/cr
rm -r ${COLLECTION_PATH_WRITABLE}/disk4/dtds
rm -r ${COLLECTION_PATH_WRITABLE}/disk5/dtds

#Robust04 has a folder with `NAME.0z`, `NAME.1z` and `NAME.2z` files, simply using gunzip
#is not an option as files are being overwritten (same name, different suffix)
#hacked solution: add ".z" to every single file in the collection path
find ${COLLECTION_PATH_WRITABLE} -name "*.0z" -type f -exec mv '{}' '{}'.z \;
find ${COLLECTION_PATH_WRITABLE} -name "*.1z" -type f -exec mv '{}' '{}'.z \;
find ${COLLECTION_PATH_WRITABLE} -name "*.2z" -type f -exec mv '{}' '{}'.z \;

#uncompress
echo "ROBUST04 ... Uncompressing"
gunzip -v --suffix=".z" -r ${COLLECTION_PATH_WRITABLE}

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
echo "ROBUST04 ... Indexing"
/work/Indri/bin/IndriBuildIndex index.param stoplist.dft