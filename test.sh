#!/bin/bash

MAX=$1
NB_TEST=$2

while [ $NB_TEST != 0 ]; do
	ARG=$(seq 1 ${MAX} | shuf)

	[ -f ./result ] && ./push_swap ${ARG} > result || ./push_swap ${ARG} >> result

	let "NB_TEST=${NB_TEST}-1"
done
