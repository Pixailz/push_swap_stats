#!/bin/bash

MAX=$1
NB_TEST=$2

# BASH COLOR :)
blue="\x1b[38;5;75m"
red="\x1b[38;5;196m"
orange="\x1b[38;5;214m"
green="\x1b[38;5;82m"
blinking="\x1b[5m"
reset="\x1b[0m"

function check_checker() {
	OLD_NB_TEST=${NB_TEST}
	[ -f "./result_checker" ] && rm ./result_checker
	while [ "$NB_TEST" != 0 ]; do
		CURRENT_LIST=$(seq 1 ${MAX} | shuf | tr '\n' ' ')
		./push_swap ${CURRENT_LIST} | ./checker_linux ${CURRENT_LIST} >> result_checker 2>>result_checker
		let "NB_TEST=${NB_TEST}-1"
	done
	nb_of_ko=$(grep 'KO' ./result_checker | wc -l)
	if [ ${nb_of_ko} == 0 ]; then
		printf "number of KO: ${green}%d${reset}\n" ${nb_of_ko}
	else
		printf "number of KO: ${blinking}${red}%d${reset}\n" ${nb_of_ko}
	fi
	nb_of_error=$(grep 'Error' ./result_checker | wc -l)
	if [ ${nb_of_error} == 0 ]; then
		printf "number of Error: ${green}%d${reset}\n" ${nb_of_error}
	else
		printf "number of Error: ${blinking}${red}%d${reset}\n" ${nb_of_error}
	fi
	NB_TEST=${OLD_NB_TEST}
}

function print_result() {
	printf "for ${blue}${NB_TEST}${reset} test on a list of length ${blue}${MAX}${reset} you have:\n"
	printf "${green}min${reset} cycle: ${orange}${result_min}${reset}\n"
	if [ ${result_med:0:1} == "." ]; then
		result_med="0${result_med}"
	fi
	printf "${orange}med${reset} cycle: ${orange}${result_med}${reset}\n"
	printf "${red}max${reset} cycle: ${orange}${result_max}${reset}\n"
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
	sort -nu ./result_cycle > sorted_cycle
	result_min=$(awk 'NR==1{print $1}' sorted_cycle)
	result_max=$(awk 'END{print}' sorted_cycle)
	NB_TEST=${OLD_NB_TEST}
	tmp_total=$(awk '{s+=$1} END {printf "%.0f", s}' result_cycle)
	result_med=$(echo "scale=2; ${tmp_total}/${NB_TEST}" | bc)
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
