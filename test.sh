#!/bin/bash

MAX=$1
NB_TEST=$2

function check_checker() {
	OLD_NB_TEST=${NB_TEST}
	[ -f "./result_checker" ] && rm ./result_checker
	while [ "$NB_TEST" != 0 ]; do
		CURRENT_LIST=$(seq 1 ${MAX} | shuf | tr '\n' ' ')
		./push_swap ${CURRENT_LIST} | ./checker_linux ${CURRENT_LIST} >> result_checker
		let "NB_TEST=${NB_TEST}-1"
	done
	nb_of_ko=$(grep 'KO' ./result_checker | wc -l)
	printf 'number of KO: %d\n'
	NB_TEST=${OLD_NB_TEST}
}

function print_result() {
	printf "for ${NB_TEST} test on a list of length ${MAX} you have:\n"
	printf "min cycle: ${result_min}\n"
	printf "max cycle: ${result_max}\n"
}

function check_cycle() {
	OLD_NB_TEST=${NB_TEST}
	[ -f "./result_cycle" ] && rm ./result_cycle
	[ -f "./tmp_cycle" ] && rm ./tmp_cycle
	while [ "$NB_TEST" != 0 ]; do
		CURRENT_LIST=$(seq 1 ${MAX} | shuf | tr '\n' ' ')
		./push_swap ${CURRENT_LIST} > tmp_cycle
		echo $(wc -l ./tmp_cycle | cut -d' ' -f1) >> result_cycle
		let "NB_TEST=${NB_TEST}-1"
	done
	sort -u ./result_cycle > sorted_cycle
	result_min=$(awk 'NR==1{print $1}' sorted_cycle)
	result_max=$(awk 'END{print}' sorted_cycle)
	NB_TEST=${OLD_NB_TEST}
	print_result
}

function clean_file() {
	[ -f "./result_checker" ] && rm ./result_checker
	[ -f "./result_cycle" ] && rm ./result_cycle
	[ -f "./tmp_cycle" ] && rm ./tmp_cycle
	[ -f "./sorted_cycle" ] && rm ./sorted_cycle
}

function main()
{
	check_checker
	check_cycle
	clean_file
}

main
