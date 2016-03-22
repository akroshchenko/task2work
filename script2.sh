#!/bin/bash

usage="script2.sh (sort|find) (version|date|vd|anom|error) name_input_file "

input_file=$3
name_of_package=mysql

print_body() {

local name=$(cut -d " " -f 1 <(echo $2))
local version=$(cut -d " " -f 2 <(echo $2))
#local name=$2
#local version=$3



flag=0
while read -r line
do
	if [ ${flag} -eq 1 ]
		then
			if [[ $line =~ ^.*--  ]]
				then 
					echo "$line"
					echo ""
					continue
			fi
			echo "$line"
	fi

	if [[ ${line} =~ .*${name}.*${version} ]] 
		then
			echo "$line"
			flag=1 
	fi
done<${input_file}


return 0
}

sort_by_version(){
#old_IFS=${IFS}

#echo "$( grep "^${name_of_package}" ${input_file} |  cut -d " " -f 1,2 |sort -r -k 2,2)" > temp
#IFS=$'\n'
#for print_package in "$( grep "^${name_of_package}" ${input_file} |  cut -d " " -f 1,2 |sort -r -k 2,2 )"
#do
#	echo "print = ${print_package}"
#	IFS=$old_IFS
echo $(grep "^${name_of_package}" ${input_file} | cut -d " " -f 1,2 | sort -r -k 2,2) >sort_temp
while read line
	do
		print_body $input_file "${line}"
	done <sort_temp    #(grep "^${name_of_package}" ${input_file} | cut -d " " -f 1,2 | sort -r -k 2,2)

#	print_body $input_file "${print_package}"

#done
echo "end of sort"

}

case $1 in
	sort)echo "sort option"
		case $2 in
			version)echo "sort by version" 
				sort_by_version 
			      ;;
			   date)
			      ;;
			     vd)
			      ;;
			      *)echo "no such parametrs in sort"
		esac
	
	  ;;		
	find)
		case $2 in
			anom)
			   ;;
		       error)
			   ;;
			   *)echo "no such parametrs in find"
		esac
	   ;;
	   *) echo "Error in the comand"
	      echo "use next syntax $usage"
esac



