#!/bin/bash

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> utils/check function

# BASH COLOR :)
blue="\x1b[38;5;75m"
red="\x1b[38;5;196m"
orange="\x1b[38;5;214m"
green="\x1b[38;5;82m"
blinking="\x1b[5m"
reset="\x1b[0m"

function usage()
{
	[ ! -z "${1}" ] && p_warn "$1"
	printf "Usage : ${0} -l NUMBER -n NUMBER \n"
	printf "\t-h : show this help\n"
	printf "\t-l : specify the length of the list\n"
	printf "\t-n : specify the number of test to do\n"
	exit
}

function p_warn()
{
	printf "[${orange}WARN ${reset}] $*\n"
}

function p_error()
{
	printf "[${red}ERROR${reset}] $*\n"
	exit
}

while [ "$1" != "" ]; do
	case $1 in
		-l)
			shift
			if [ -z ${1} ]; then
				usage "-l must be followed by a length"
			else
				LENGTH="${1}"
			fi
			;;
		-n)
			shift
			if [ -z ${1} ]; then
				usage "-n must be followed by the number of test"
			else
				NB_TEST=${1}
			fi
			;;
		-h)
			usage
			;;
		*)
			usage "Wrong args"
			;;
	esac
	shift
done

function check_arg()
{
	if [ -z ${NB_TEST} ]; then
		usage "(-n) must be specified"
	elif [ -z ${LENGTH} ]; then
		usage "(-l) must be specified"
	fi
	case ${NB_TEST} in
		''|*[!0-9]*)
			usage "-n take a number in argument."
			;;
	esac
	case ${LENGTH} in
		''|*[!0-9]*)
			usage "-l take a number in argument."
			;;
	esac
}

check_arg
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> main function

function init_random_list()
{
	index=0
	while [ "${index}" -lt "${NB_TEST}" ]; do
		random_list[${index}]=$(seq 1 ${LENGTH} | shuf | tr '\n' ' ')
		let "index=${index}+1"
	done
}

function exec_push_swap()
{
	index=0
	while [ "${index}" -lt "${NB_TEST}" ]; do
		printf "list number %d\r" $((${index} + 1))
		./push_swap ${random_list[${index}]} > tmp_cycle
		echo $(wc -l ./tmp_cycle | cut -d' ' -f1) >> result_cycle
		cat ./tmp_cycle | ./checker_linux ${random_list[${index}]} >> result_checker 2>>result_checker
		let "index=${index}+1"
	done
	echo
}

function  parse_result ()
{
	nb_of_ko=$(grep 'KO' ./result_checker | wc -l)
	nb_of_error=$(grep 'Error' ./result_checker | wc -l)
	sort -nu ./result_cycle > sorted_cycle
	result_min=$(awk 'NR==1{print $1}' sorted_cycle)
	result_max=$(awk 'END{print}' sorted_cycle)
	tmp_total=$(awk '{s+=$1} END {printf "%.0f", s}' result_cycle)
	result_med=$(echo "scale=2; ${tmp_total}/${NB_TEST}" | bc)
}

function print_error_list()
{
	index=1
	while [ "${index}" -lt "${NB_TEST}" ]; do
		current_result=$(sed -n "${index}p" ./result_checker)
		if [ ${current_result} == "KO" ]; then
			printf "${random_list[$((${index} - 1))]}has ${red}failed${reset}\n"
		fi
		let "index=${index}+1"
	done
}

function print_result()
{
	if [ ${nb_of_ko} == 0 ]; then
		printf "number of KO: ${green}%d${reset}\n" ${nb_of_ko}
	else
		print_error_list
		printf "number of KO: ${blinking}${red}%d${reset}\n" ${nb_of_ko}
	fi
	if [ ${nb_of_error} == 0 ]; then
		printf "number of Error: ${green}%d${reset}\n" ${nb_of_error}
	else
		printf "number of Error: ${blinking}${red}%d${reset}\n" ${nb_of_error}
	fi
	printf "for ${blue}${NB_TEST}${reset} test on a list of length ${blue}${LENGTH}${reset} you have:\n"
	printf "${green}min${reset} cycle: ${orange}${result_min}${reset}\n"
	if [ ${result_med:0:1} == "." ]; then
		result_med="0${result_med}"
	fi
	printf "${orange}med${reset} cycle: ${orange}${result_med}${reset}\n"
	printf "${red}max${reset} cycle: ${orange}${result_max}${reset}\n"
}

function clean_file()
{
	[ -f "./result_checker" ] && rm -f ./result_checker
	[ -f "./result_cycle" ] && rm -f ./result_cycle
	[ -f "./tmp_cycle" ] && rm -f ./tmp_cycle
	[ -f "./sorted_cycle" ] && rm -f ./sorted_cycle
}

function main ()
{
	clean_file
	init_random_list
	exec_push_swap
	parse_result
	print_result
	clean_file
}

main
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
