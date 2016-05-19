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
#- This list contain the name of packages from INPUT_FILE in special order.
print_body(){

local OUTPUT_LIST_ORDER=$1
local NAME
local VERSION

while read -r line_1; do
		NAME="$(echo "${line_1}"|cut -d " " -f 1)"
		VERSION="$(echo "${line_1}"|cut -d " " -f 2)"
		FLAG=0
		while read -r line; do
			if [ ${FLAG} -eq 1 ]; then
				if echo "${line}" |grep -qE "\-\- "; then
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
	done<${OUTPUT_LIST_ORDER}

}


sort_by_version(){

VER_SORT_TEMP=$(mktemp -t VER_SORT_TEMP.XXXXX)
echo "$(grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" | cut -d " " -f 1,2 | sort -k 2,2Vr)" >${VER_SORT_TEMP}
echo "List of the packages sorting by version store in ${VER_SORT_TEMP}"

}


analyze_date(){

INPUT_LINE=$1

PREPARED_LINE="$(echo "${INPUT_LINE}"| tr -s [:blank:] | grep -Ew "(Sun,|Mon,|Tue,|Wed,|Thu,|Fri,|Sat).*" | cut -d " " -f 2- )"
		year="$(echo "${PREPARED_LINE}" | cut -d " " -f 3)"
		month="$(echo "${PREPARED_LINE}" | cut -d " " -f 2)"
		day="$(echo "${PREPARED_LINE}" | cut -d " " -f 1)"
		hour="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 1)"	
		extra_hour="$(echo "${PREPARED_LINE}" | cut -d " " -f 5 | cut -c 1,2,3)"
		minute="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 2)"
		extra_minute="$(echo "${PREPARED_LINE}" | cut -d " " -f 5 | cut -c 1,4,5)"
		sec="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 3)"

		if [ ${real_minute=$(( minute - extra_minute ))} -ge 60 ]; then 
			hour=$(( hour +1 ))
			minute=$((minute - 60))
		elif [ ${real_minute=$(( minute - extra_minute ))} -lt 0 ]; then 
			hour=$(( hour - 1 ))
			minute=$((minute + 60))
		fi

		if [ ${real_hour=$((hour - extra_hour))} -ge 24 ]; then
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

	fi	
return "$(echo "year month day hour minute sec" |sed -e s/Jan/1/g -e s/Feb/2/g \
	-e s/Mar/3/g -e s/Apr/4/g -e s/May/5/g -e s/jun/6/g \
	-e s/jul/7/g -e s/Aug/8/g -e s/jSep/9/g -e s/Oct/10/g \
	-e s/Nov/11/g -e s/Dec/12/g -e "s/ //g")"
}


looking_for_anomalies(){

local date_1
local date_2
local NAME_package_1
local NAME_package_2
local VERSION_1
local VERSION_2
local line
local year
local month
local day
local hour
local extra_hour
local minute
local extra_minute
local sec

while read -r line; do
	if $(echo "${line}" |grep -q "^${GLOBAL_NAME_OF_PACKAGE}"); then
		NAME_PACKAGE_1="$( echo "${line}" |cut -d " " -f 1 )"
		VERSION_1="$( echo "${line}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
	fi
	if echo "${line}" | grep "<.*@.*>" | grep -q "--" --; then
		date_1="$(analyze_date ${line})"
	fi
	while read -r line_1; do
		if $(echo "${line_1}" |grep -q "^${GLOBAL_NAME_OF_PACKAGE}"); then
		NAME_PACKAGE_2="$( echo "${line_1}" |cut -d " " -f 1 )"
		VERSION_2="$( echo "${line_1}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
		fi
		if echo "${line_1}" | grep "<.*@.*>" | grep -q "--" --; then
		date_2="$(analyze_date ${line_1})"
		fi
		if [ "${NAME_package_1}" = "${NAME_package_2}" ]; then
			if [ "${VERSION_1}" = "${VERSION_2}" ]; then
				continue
			fi
		#	echo "vers1= ${VERSION_1} date_1= ${date_1} vers2= ${VERSION_2} date_2= ${date_2}"
			if dpkg --compare-VERSIONs "${VERSION_1}" gt "${VERSION_2}"; then 
				if [ "${date_1}" -gt "${date_2}" ]; then 
					continue
				else
					echo "anomaly is among (${NAME_PACKAGE_1} ${VERSION_1}) (${NAME_PACKAGE_2} ${VERSION_2})"
				fi
			else 
				if [ "${date_1}" -lt "${date_2}" ]; then
					continue
				else
					echo "anomaly is among (${NAME_PACKAGE_1} ${VERSION_1}) (${NAME_PACKAGE_2} ${VERSION_2})"
				fi
			fi
		fi
	done<${VER_SORT_TEMP}
done<${VER_SORT_TEMP}
}


check_epoch(){

if grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" |grep -q ":" ; then
	sed -i "${GLOBAL_NAME_OF_PACKAGE}.*([0-9][^:]/s/(/(0:/g" "${INPUT_FILE}"
	echo "EPOCH PRESENT"
esac

}


dell_null_epoch(){

sed -i "${GLOBAL_NAME_OF_PACKAGE}.*(0:/s/(0:/(/g" "${INPUT_FILE}"

}

looking_for_format_errors(){

FORMATING_ERROR=$(mktemp -t FORMATING_ERROR.XXXXX)

echo -E "Looking for the format errors =====>"
grep -E "^${GLOBAL_NAME_OF_PACKAGE}.*\(.*\).*" "${INPUT_FILE}" | \
grep -Ev "^${GLOBAL_NAME_OF_PACKAGE}.*[[:space:]]{1}\(([0-9]:)?[0-9\.[0-9]\..*" >>${FORMATING_ERROR}

grep -E "^[[:space:]]+${GLOBAL_NAME_OF_PACKAGE}.* \(.*\)" "${INPUT_FILE}" >>${FORMATING_ERROR}

grep -E "^[[:space:]]*--.*>[[:space:]]*(Mon, |Tue, |Wed, |Thu, |Fri, |Sat, |Sun)" \
 "${INPUT_FILE}" |grep -vE "^[[:space:]]{1}--.*>[[:space:]]{2}(Mon, |Tue, |Wed, |Thu, |Fri, |Sat, |Sun)" >>${FORMATING_ERROR}
 if [ -s ${FORMATING_ERROR} ]; then
 	echo "Correct next formating errors:"
 	cat ${FORMATING_ERROR}
 fi
 rm -rf ${FORMATING_ERROR}

}


# the logic of script

check_epoch
looking_for_format_errors
sort_by_version
looking_for_anomalies
print_body ${VER_SORT_TEMP} >${INPUT_FILE}
dell_null_epoch
