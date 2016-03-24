#!/bin/bash

usage="script2.sh (sort|find) (version|date|vd|anom|error) name_input_file "

input_file=$3
name_of_package=mysql

print_body(){

local name=$(cut -d " " -f 1 <(echo $2))
local version=$(cut -d " " -f 2 <(echo $2))



flag=0
while read -r line
do
	if [ ${flag} -eq 1 ]
		then

			if echo "${line}" |grep -E "\-\- ">/dev/null
				then

					echo "$line"
					echo ""
					break
			fi
			echo "$line"
	fi

	if [[ ${line} =~ .*${name}.*${version} ]] 
		then

			echo "$line"
			flag=1 
	fi
done<${input_file}


#return 0
}

sort_by_version(){


echo "$(grep "^${name_of_package}" ${input_file} | cut -d " " -f 1,2 | sort -k 2,2Vr)" >ver_sort_temp
while read line
	do
		print_body $input_file "${line}"
	done <ver_sort_temp    
}


sort_by_date(){
echo "func sort_by_date"
local M
local real_hour
local real_minutr
local extra_hour
local extra_minute
local hour
local minute
local sec
local month
local year
local day
local my_line
local name_version

:>date_sort_temp
while read -r line_row
do

	if echo "${line_row}" | grep "^${name_of_package}">/dev/null
		then 
			name_version="$(echo -n "$(echo "${line_row}" | grep "^${name_of_package}" |cut -d " " -f 1,2)")"
	fi


	if echo "${line_row}" | grep "<.*@.*>" | grep "\-\-">/dev/null
		then

			my_line=${name_version}				
			line="$(echo "${line_row}"| tr -s [:blank:] | grep -Eow "(Sun,|Mon,|Tue,|Wed,|Thu,|Fri,|Sat).*" | cut -d " " -f 2- )"

			year="$(echo "${line}" | cut -d " " -f 3)"
			month="$(echo "${line}" | cut -d " " -f 2)"
			day="$(echo "${line}" | cut -d " " -f 1)"
			hour="$(echo "${line}" | cut -d " " -f 4 | cut -d ":" -f 1)"	
			extra_hour="$(echo "${line}" | cut -d " " -f 5 | cut -c 1,2,3)"
			minute="$(echo "${line}" | cut -d " " -f 4 | cut -d ":" -f 2)"
			extra_minute="$(echo "${line}" | cut -d " " -f 5 | cut -c 1,4,5)"
			sec="$(echo "${line}" | cut -d " " -f 4 | cut -d ":" -f 3)"
			
			if [ ${real_minute=$(( minute - extra_minute ))} -ge 60 ]
				then 
					hour=$(( hour +1 ))
			fi

			if [ ${real_hour=$((hour - extra_hour))} -gt 24 ]
				then
					day=$(( day +1))
			fi				
			my_line="${my_line} ${year} ${month} ${day} ${hour} ${minute} ${sec}"
			echo "${my_line}">>date_sort_temp

	fi	


done<"${input_file}"






while read -r line
do

	print_body ${input_file} "${line}"
done < <(sort -t " " -k3,3r -k4,4Mr -k5,5r -k6,6r -k7,7r -k8,8r date_sort_temp |cut -d " " -f 1,2)


}


case $1 in
	sort)echo "sort option"
		case $2 in
			version)echo "sort by version" 
				sort_by_version 
			      ;;
			   date)echo "sort by date"
				sort_by_date 
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
