#!/bin/bash

SEARCH_WORD=$1
SEARCH_LOG=$2
DATE=`date`

if grep $SEARCH_WORD $SEARCH_LOG &>/dev/null
then
	logger "$DATE: Found word: $SEARCH_WORD in log file: $SEARCH_LOG"
else
	exit 0
fi