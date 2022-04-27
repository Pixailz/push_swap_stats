#!/bin/bash

[ "$1" -le 1 ] && exit
[ -z $2 ] && exit
[ -f result ] && rm -f result

MAX=$1
NB_TEST=$2

while [ "$NB_TEST" != 0 ]; do
	ARG=$(seq 1 ${MAX} | shuf)
	./push_swap ${ARG} | sed -nE 's|Cycle : ([0-9]*)|\1|p' >> result
	let "NB_TEST=${NB_TEST}-1"
done

cat ./result | sort -u -o result

result_min=$(awk 'NR==1{print $1}' result)
result_max=$(awk 'END{print}' result)

printf "for ${2} test on a list of length ${1} you have:\n"
printf "min cycle: ${result_min}\n"
printf "max cycle: ${result_max}\n"
