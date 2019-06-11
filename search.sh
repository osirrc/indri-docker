#!/usr/bin/env bash

INDEX=$1;
TOPICFILE=$2;
TOPK=$3;
RESFILE=$4;
SEARCHRULE=$5;
TOPICTYPE=$6;

TOPICFILE_FORMATTED = $2"-INDRI";
#reformat the topicfile (original TREC format) into one Indri can process
perl topicFormatting.pl ${TOPICFILE} ${TOPICFILE_FORMATTED} ${TOPICTYPE}

#parameter file for searching
touch search.param;
echo "<parameters>" >> search.param;
echo "<index>/work/${INDEX}</index>" >> search.param;
echo "<count>${TOPK}</count>" >> search.param;
echo "<rule>${SEARCHRULE}</rule>" >> search.param;
echo "<trecFormat>true</trecFormat>" >> search.param;
echo "</parameters>" >> search.param;

#show off the parameter file
more search.param

#start searching
echo "Processing topic file ..."
/work/Indri/bin/IndriRunQuery search.param ${TOPICFILE_FORMATTED} >> ${RESFILE}