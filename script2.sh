#!/bin/bash

set -o errexit
set -x # delete after debug

USAGE="script2.sh sort (version|date|vd) | find (anom|error) CHANGELOG_FILE"

INPUT_FILE="${3}"

if [ -z "$(head -n 1 ${INPUT_FILE})" ];then
	echo "File ${INPUT_FILE} contains empty first line"
	exit 1
fi

GLOBAL_NAME_OF_PACKAGE="$(head -n 1 ${INPUT_FILE} |cut -d" " -f1|cut -d"-" -f1)"

# This function takes a list of packages which need to print. 
#- This list contain the NAME of packages from INPUT_FILE in special order.
print_body(){

local OUTPUT_LIST=$1
local NAME
local VERSION

while read -r line_1; do
		NAME="$(echo "${line_1}"|cut -d " " -f 1)"
		VERSION="$(echo "${line_1}"|cut -d " " -f 2)"
		
		FLAG=0

		while read -r line; do
			if [ ${FLAG} -eq 1 ]; then
				if echo "${line}" |grep -E "\-\- ">/dev/null; then
					echo "$line"
					echo ""
					break
				fi
				echo "$line"
			fi
		
			if echo "${line}" | grep -q "${NAME}" && echo "${line}" | grep -q "${VERSION}"; then
				echo "$line"
				FLAG=1
				else 
					echo "probram with NAME VERSION matching" # delete after debug
				fi
		done<${INPUT_FILE}
	done<${OUTPUT_LIST}

}


sort_by_version(){

VER_SORT_TEMP=$(mktemp -t VER_SORT_TEMP.XXXXX)
echo "$(grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" | cut -d " " -f 1,2 | sort -k 2,2Vr)" >VER_SORT_TEMP
echo "List of the packages sorting by version store in ${VER_SORT_TEMP}"
}


sort_by_date(){

PRE_DATE_SORT_TEMP=$(mktemp -t DATE_SORT_TEMP.XXXXX)
DATE_SORT_TEMP=$(mktemp -t DATE_SORT_TEMP.XXXXX)
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
local NAME_VERSION
local visoc_year=0

while read -r line_row; do

	if echo "${line_row}" | grep "^${GLOBAL_NAME_OF_PACKAGE}">/dev/null; then 
			NAME_VERSION="$(echo -n "$(echo "${line_row}" | grep "^${GLOBAL_NAME_OF_PACKAGE}" |cut -d " " -f 1,2)")"
	fi

	if echo "${line_row}" | grep "<.*@.*>" | grep "\-\-">/dev/null;then
		my_line="${NAME_VERSION}"				
		line="$(echo "${line_row}"| tr -s [:blank:] | grep -Eow "(Sun,|Mon,|Tue,|Wed,|Thu,|Fri,|Sat).*" | cut -d " " -f 2- )"
		year="$(echo "${line}" | cut -d " " -f 3)"
		month="$(echo "${line}" | cut -d " " -f 2)"
		day="$(echo "${line}" | cut -d " " -f 1)"
		hour="$(echo "${line}" | cut -d " " -f 4 | cut -d ":" -f 1)"	
		extra_hour="$(echo "${line}" | cut -d " " -f 5 | cut -c 1,2,3)"
		minute="$(echo "${line}" | cut -d " " -f 4 | cut -d ":" -f 2)"
		extra_minute="$(echo "${line}" | cut -d " " -f 5 | cut -c 1,4,5)"
		sec="$(echo "${line}" | cut -d " " -f 4 | cut -d ":" -f 3)"

		if [ ${real_minute=$(( minute - extra_minute ))} -ge 60 ]; then 
			hour=$(( hour +1 ))
			minute=$((minute - 60))
		elif [ ${real_minute=$(( minute - extra_minute ))} -lt 0 ]; then 
			hour=$(( hour - 1 ))
			minute=$((minute + 60))
		fi

		if [ ${real_hour=$((hour - extra_hour))} -gt 24 ]; then
			day=$(( day +1))
			hour=$((hour - 24))
		elif [ "${real_hour}" -lt 0 ]; then
			day=$(( day - 1))
			real_hour=$((real_hour + 24))
		fi

		if [ $((year % 4)) -eq 0 -a $((year%100)) -ne 0 ]; then 
			visoc_year=1
			if [ "${month}" = "Feb" ]; then 
				if [ $(day) -qt 29]; then 
					month=Mar
					day=$((day-29))
				fi
			fi
		elif [ $((year%400)) -eq 0 ]; then 
			visoc_year=1
			if [ "${month}" = "Feb" ]; then 
				if [ $(day) -qt 29]; then 
					month=Mar
					day=$((day-29))
				fi
			fi
		else 
			visoc_year=0
			if  [ "${month}" = "Feb" ]; then 
				if [ $(day) -qt 28 ]; then 
					month=Mar
					day=$((day-28))
				fi
			fi
		fi
		case "${month}" in 
			Jan)
				if [ "${day}" -gt 31]; then			
					day=$((day - 31))
					month=Feb
				fi
				if [ "${day}" -le 0 ]; then
					day=31
					mont=Dec
					year=$((year - 1))
				fi
				;;
			Feb)
				if [ "${day}" -le 0 ]; then 
					day=31
					nonth=Jan
				fi
				;;
			Mar) 
				if [ "${day}" -gt 31 ]; then
        	        day=$((day - 31))
                	month=Apr
				fi
				if [ "${day}" -le 0 ]; then
					if [ "${visoc_year}" -eq 1 ]; then
						day=29
					else
						day=28
					fi
					mont=Feb
				fi
				;;
			Apr)
				if [ "${day}" -gt 30 ]; then
					day=$((day - 30))
					month=May
				fi
				if [ "${day}" -le 0 ]; then
        	        day=31
                	mont=Mar
				fi
				;;
       		May)
				if [ "${day}" -gt 31]; then
					day=$((day - 31))
                    month=Jun
				fi
				if [ "${day}" -le 0 ]; then
					day=30
					mont=Apr
				fi
				;;
			Jun)
				if [ "${day}" -gt 30 ]; then
					day=$((day - 30))
					month=Jul
				fi
				if [ "${day}" -le 0 ]; then
				    day=31
					mont=May
				fi
				;;
            Jul)
				if [ "${day}" -gt 31]; then
					day=$((day - 31))
					month=Aug
				fi

				if [ "${day}" -le 0 ]; then
					day=30
					mont=Jun
				fi
				;;
			Aug)
				if [ "${day}" -gt 31]; then
					day=$((day - 31))
					month=Sep
				fi
				if [ "${day}" -le 0 ]; then
					day=31
					mont=Jul
				fi
				;;
			Sep)
				if [ "${day}" -gt 30 ]; then
					day=$((day - 30))
					month=Oct
				fi
				if [ "${day}" -le 0 ]; then
					day=31
					mont=Aug
				fi
				;;
			Oct)
				if [ "${day}" -gt 31 ]; then
					day=$((day - 31))
					month=Nov
				fi

				if [ "${day}" -le 0 ]; then
					day=30
					mont=Sep
				fi
				;;
			Nov)
				if [ "${day}" -gt 30 ]; then
					day=$((day - 30))
					month=Dec
				fi
				if [ "${day}" -le 0 ]; then
					day=31
					mont=Oct
				fi
				;;
			Dec)
				if [ "${day}" -gt 31 ]; then
					day=$((day - 31))
					month=Jan
					year=$(( year + 1))
				fi
				if [ "${day}" -le 0 ]; then
					day=30
					mont=Nov
				fi
			esac
		# my_line="${my_line} ${year} ${month} ${day} ${hour} ${minute} ${sec}" delete after debug
		# echo "${my_line}">>DATE_SORT_TEMP
		echo "${my_line} ${year} ${month} ${day} ${hour} ${minute} ${sec}" >>PRE_DATE_SORT_TEMP
	fi	
done<"${INPUT_FILE}"
sort -t " " -k3,3r -k4,4Mr -k5,5r -k6,6r -k7,7r -k8,8r PRE_DATE_SORT_TEMP > DATE_SORT_TEMP

echo "Date before sorting stores in ${PRE_DATE_SORT_TEMP}"
echo "Sorting by date date stores in ${DATE_SORT_TEMP}"
}


looking_for_anomalies(){

local date_1
local date_2
local NAME_package_1
local NAME_package_2
local VERSION_1
local VERSION_2

while read -r line; do
	NAME_package_1="$( echo "${line}" |cut -d " " -f 1 )"
	VERSION_1="$( echo "${line}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
	date_1="$(echo "${line}" |cut -d " " -f 3- |sed -e s/jan/1/g -e s/Feb/2/g \
	-e s/Mar/3/g -e s/Apr/4/g -e s/May/5/g -e s/jun/6/g \
	-e s/jul/7/g -e s/Aug/8/g -e s/jSep/9/g -e s/Oct/10/g \
	-e s/Nov/11/g -e s/Dec/12/g -e "s/ //g")"
	while read -r line_1; do
		NAME_package_2="$( echo "${line_1}" |cut -d " " -f 1 )"
		VERSION_2="$( echo "${line_1}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
		date_2="$(echo "${line_1}" |cut -d " " -f 3- |sed -e s/jan/1/g \
        -e s/Feb/2/g -e s/Mar/3/g -e s/Apr/4/g \
        -e s/May/5/g -e s/jun/6/g -e s/jul/7/g \
        -e s/Aug/8/g -e s/jSep/9/g -e s/Oct/10/g \
        -e s/Nov/11/g -e s/Dec/12/g -e "s/ //g")"
	#	echo "first: ${NAME_package_1} ${VERSION_1} ${date_1}"
	#	echo "first: ${NAME_package_2} ${VERSION_2} ${date_2}"
		if [ "${NAME_package_1}" = "${NAME_package_2}" ]; then
			if [ "${VERSION_1}" = "${VERSION_2}" ]; then
				continue
			fi
		#	echo "vers1= ${VERSION_1} date_1= ${date_1} vers2= ${VERSION_2} date_2= ${date_2}"
			if dpkg --compare-VERSIONs "${VERSION_1}" gt "${VERSION_2}"; then 
				if [ "${date_1}" -gt "${date_2}" ]; then 
					continue
				else
					echo "anomaly is among (${NAME_1} ${VERSION_1}) (${NAME_2} ${VERSION_2})"
				fi
			else 
				if [ "${date_1}" -lt "${date_2}" ]; then
					continue
				else
					echo "anomaly is among (${NAME_1} ${VERSION_1}) (${NAME_2} ${VERSION_2})"
				fi
			fi
		fi
	done<date_sort_temp
done<date_sort_temp
}


check_epoch(){

if grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" |grep -q ":" ; then
	sed -i "${GLOBAL_NAME_OF_PACKAGE}.*([0-9][^:]/s/(/(0:/g" "${INPUT_FILE}"
	echo "epoch present"
esac

}


dell_null_epoch(){

sed -i "${GLOBAL_NAME_OF_PACKAGE}.*(0:/s/(0:/(/g" "${INPUT_FILE}"

}

looking_for_errors(){

echo -E "Looking for the format errors =====>"
grep -E "^${GLOBAL_NAME_OF_PACKAGE}.*\(.*\).*" "${INPUT_FILE}" | \
grep -Ev "^${GLOBAL_NAME_OF_PACKAGE}.*[[:space:]]{1}\(([0-9]:)?[0-9\.[0-9]\..*"

grep -E "^[[:space:]]+${GLOBAL_NAME_OF_PACKAGE}.* \(.*\)" "${INPUT_FILE}" 

grep -E "^[[:space:]]*--.*>[[:space:]]*(Mon, |Tue, |Wed, |Thu, |Fri, |Sat, |Sun)" \
 "${INPUT_FILE}" |grep -vE "^[[:space:]]{1}--.*>[[:space:]]{2}(Mon, |Tue, |Wed, |Thu, |Fri, |Sat, |Sun)"

}


# the logic of script

check_epoch

case $1 in
		sort)echo "sort option"
			case $2 in
				version)echo "sort by VERSION" 
					sort_by_version
					print_body VER_SORT_TEMP
				      ;;
				   date)echo "sort by date"
					sort_by_date 
					print_body <(cut -d " " -f 1,2 date_sort_temp)
				      ;;
				     vd)
				      ;;
				      *)echo "no such parametrs in sort"
						echo ${USAGE}
			esac
		
		;;		
		find)
			case $2 in
					anom)
						sort_by_date
						looking_for_anomalies
				    ;;
			        error)
						looking_for_errors
				    ;;
				   *)
					echo "no such parametrs in find"
					echo ${USAGE}
					exit 1
			esac
		;;
		*) echo "Error in the comand"
		   echo "use next syntax :"
		   echo "	$USAGE"
		   exit 1
esac

dell_null_epoch