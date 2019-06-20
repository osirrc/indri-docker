#!/usr/bin/env bash

#Indri is having its own specific file format, not aligned with the TREC topic format.
#search.sh works for both robust04 and gov2

INDEX="/"$1
TOPICFILE=$2
TOPK=$3
RESFILE="/output/"$4
SEARCHRULE=$5
TOPICTYPE=$6
TOPICFILE_FORMATTED="/topics-INDRI"
USEPRF=$7
SD=$8

#Reformat the topicfile (original TREC format) into one Indri can process
perl /topicFormatting.pl "${TOPICFILE}" "${TOPICFILE_FORMATTED}" "${TOPICTYPE}" "${SEARCHRULE}" "${SD}"

#sanity check - first 10 lines of the new topic file
echo "${INDEX} ... first few lines of the topic file"
head ${TOPICFILE_FORMATTED}

#parameter file for searching
touch search.param
echo "<parameters>" >> search.param
echo "<index>${INDEX}</index>" >> search.param
echo "<count>${TOPK}</count>" >> search.param
if [[ ${SEARCHRULE} == *tfidf* ]] || [[ ${SEARCHRULE} == *okapi* ]]
then
    echo "<baseline>${SEARCHRULE}</baseline>" >> search.param
else
    echo "<rule>${SEARCHRULE}</rule>" >> search.param
fi
echo "<trecFormat>true</trecFormat>" >> search.param

if [[ ${USEPRF} == 1 ]]
then
    echo "<fbDocs>50</fbDocs>" >> search.param
    echo "<fbTerms>25</fbTerms>" >> search.param
    echo "<fbOrigWeight>0.5</fbOrigWeight>" >> search.param
fi
echo "</parameters>" >> search.param

#printout
more search.param

#start searching
echo "${INDEX} ... Processing topics"
/work/Indri/bin/IndriRunQuery search.param ${TOPICFILE_FORMATTED} >> ${RESFILE}
