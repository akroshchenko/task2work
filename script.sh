#!/bin/bash

set -o errexit
set -x # delete after debug

USAGE="script2.sh sort (version|date|vd) | find (anom|error) CHANGELOG_FILE"

INPUT_FILE="${3}"

if [ -z "$(head -n 1 ${INPUT_FILE})" ];then
	echo "File ${INPUT_FILE} contains empty first LINE"
	exit 1
fi

GLOBAL_NAME_OF_PACKAGE="$(head -n 1 ${INPUT_FILE} |cut -d" " -f1|cut -d"-" -f1)"

# This function takes a list of PACKAGEs which need to print. 
#- This list contain the name of PACKAGEs from INPUT_FILE in special order.
print_body(){

local INPUT_ORDER=$1
local NAME
local VERSION

while read -r LINE_1; do
		NAME="$(echo "${LINE_1}"|cut -d " " -f 1)"
		VERSION="$(echo "${LINE_1}"|cut -d " " -f 2)"
		FLAG=0
		while read -r LINE; do
			if [ ${FLAG} -eq 1 ]; then
				if echo "${LINE_1}" | grep "<.*@.*>" | grep -q "--" --
					echo "$LINE_1"
					echo ""
					break
				fi
				echo "$LINE_1"
			fi
		
			if echo "${LINE_1}" | grep -q "${NAME}" && echo "${LINE_1}" | grep -q "${VERSION}"; then
				echo "$LINE_1"
				FLAG=1
			else 
					echo "probram with NAME VERSION matching" # delete after debug
			fi
		done<${INPUT_FILE}
	done<${INPUT_ORDER}

}


sort_by_version(){

VER_SORT_TEMP=$(mktemp -t VER_SORT_TEMP.XXXXX)
echo "$(grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" | cut -d " " -f 1,2 | sort -k 2,2Vr)" >${VER_SORT_TEMP}
echo "List of the PACKAGEs sorting by version store in ${VER_SORT_TEMP}"

}


analyze_date(){

INPUT_LINE=$1
local YEAR MONTH DAY YEAR HOUR EXTRA_HOUR MINUTE EXTRA_MINUTE SEC REAL_MINUTE REAL_HOUR

PREPARED_LINE="$(echo "${INPUT_LINE}"| tr -s [:blank:] | grep -Ew "(Sun,|Mon,|Tue,|Wed,|Thu,|Fri,|Sat).*" | cut -d " " -f 2- )"
		YEAR="$(echo "${PREPARED_LINE}" | cut -d " " -f 3)"
		MONTH="$(echo "${PREPARED_LINE}" | cut -d " " -f 2)"
		DAY="$(echo "${PREPARED_LINE}" | cut -d " " -f 1)"
		HOUR="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 1)"	
		EXTRA_HOUR="$(echo "${PREPARED_LINE}" | cut -d " " -f 5 | cut -c 1,2,3)"
		MINUTE="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 2)"
		EXTRA_MINUTE="$(echo "${PREPARED_LINE}" | cut -d " " -f 5 | cut -c 1,4,5)"
		SEC="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 3)"

		if [ ${REAL_MINUTE=$(( MINUTE - EXTRA_MINUTE ))} -ge 60 ]; then 
			HOUR=$(( HOUR +1 ))
			MINUTE=$((MINUTE - 60))
		elif [ ${REAL_MINUTE=$(( MINUTE - EXTRA_MINUTE ))} -lt 0 ]; then 
			HOUR=$(( HOUR - 1 ))
			MINUTE=$((MINUTE + 60))
		fi

		if [ ${REAL_HOUR=$((HOUR - EXTRA_HOUR))} -ge 24 ]; then
			DAY=$(( DAY +1))
			HOUR=$((HOUR - 24))
		elif [ "${REAL_HOUR}" -lt 0 ]; then
			DAY=$(( DAY - 1))
			REAL_HOUR=$((REAL_HOUR + 24))
		fi

		if [ $((YEAR % 4)) -eq 0 -a $((YEAR%100)) -ne 0 ]; then 
			VISOC_YEAR=1
			if [ "${MONTH}" = "Feb" ]; then 
				if [ $(DAY) -qt 29]; then 
					MONTH=Mar
					DAY=$((DAY-29))
				fi
			fi
		elif [ $((YEAR%400)) -eq 0 ]; then 
			VISOC_YEAR=1
			if [ "${MONTH}" = "Feb" ]; then 
				if [ $(DAY) -qt 29]; then 
					MONTH=Mar
					DAY=$((DAY-29))
				fi
			fi
		else 
			VISOC_YEAR=0
			if  [ "${MONTH}" = "Feb" ]; then 
				if [ $(DAY) -qt 28 ]; then 
					MONTH=Mar
					DAY=$((DAY-28))
				fi
			fi
		fi
		case "${MONTH}" in 
			Jan)
				if [ "${DAY}" -gt 31]; then			
					DAY=$((DAY - 31))
					MONTH=Feb
				fi
				if [ "${DAY}" -le 0 ]; then
					DAY=31
					MONTH=Dec
					YEAR=$((YEAR - 1))
				fi
				;;
			Feb)
				if [ "${DAY}" -le 0 ]; then 
					DAY=31
					MONTH=Jan
				fi
				;;
			Mar) 
				if [ "${DAY}" -gt 31 ]; then
        	        DAY=$((DAY - 31))
                	MONTH=Apr
				fi
				if [ "${DAY}" -le 0 ]; then
					if [ "${VISOC_YEAR}" -eq 1 ]; then
						DAY=29
					else
						DAY=28
					fi
					MONTH=Feb
				fi
				;;
			Apr)
				if [ "${DAY}" -gt 30 ]; then
					DAY=$((DAY - 30))
					MONTH=May
				fi
				if [ "${DAY}" -le 0 ]; then
        	        DAY=31
                	MONTH=Mar
				fi
				;;
       		May)
				if [ "${DAY}" -gt 31]; then
					DAY=$((DAY - 31))
                    MONTH=Jun
				fi
				if [ "${DAY}" -le 0 ]; then
					DAY=30
					MONTH=Apr
				fi
				;;
			Jun)
				if [ "${DAY}" -gt 30 ]; then
					DAY=$((DAY - 30))
					MONTH=Jul
				fi
				if [ "${DAY}" -le 0 ]; then
				    DAY=31
					MONTH=May
				fi
				;;
            Jul)
				if [ "${DAY}" -gt 31]; then
					DAY=$((DAY - 31))
					MONTH=Aug
				fi

				if [ "${DAY}" -le 0 ]; then
					DAY=30
					MONTH=Jun
				fi
				;;
			Aug)
				if [ "${DAY}" -gt 31]; then
					DAY=$((DAY - 31))
					MONTH=Sep
				fi
				if [ "${DAY}" -le 0 ]; then
					DAY=31
					MONTH=Jul
				fi
				;;
			Sep)
				if [ "${DAY}" -gt 30 ]; then
					DAY=$((DAY - 30))
					MONTH=Oct
				fi
				if [ "${DAY}" -le 0 ]; then
					DAY=31
					MONTH=Aug
				fi
				;;
			Oct)
				if [ "${DAY}" -gt 31 ]; then
					DAY=$((DAY - 31))
					MONTH=Nov
				fi

				if [ "${DAY}" -le 0 ]; then
					DAY=30
					MONTH=Sep
				fi
				;;
			Nov)
				if [ "${DAY}" -gt 30 ]; then
					DAY=$((DAY - 30))
					MONTH=Dec
				fi
				if [ "${DAY}" -le 0 ]; then
					DAY=31
					MONTH=Oct
				fi
				;;
			Dec)
				if [ "${DAY}" -gt 31 ]; then
					DAY=$((DAY - 31))
					MONTH=Jan
					YEAR=$(( YEAR + 1))
				fi
				if [ "${DAY}" -le 0 ]; then
					DAY=30
					MONTH=Nov
				fi
			esac

	fi	
return "$(echo "${YEAR} ${MONTH} ${DAY} ${REAL_HOUR} ${REAL_MINUTE} ${SEC}" |sed -e s/Jan/1/g -e s/Feb/2/g \
	-e s/Mar/3/g -e s/Apr/4/g -e s/May/5/g -e s/jun/6/g \
	-e s/jul/7/g -e s/Aug/8/g -e s/jSep/9/g -e s/Oct/10/g \
	-e s/Nov/11/g -e s/Dec/12/g -e "s/ //g")"
}


looking_for_anomalies(){

local DATE_1 DATE_2 NAME_PACKAGE_1 NAME_PACKAGE_2 VERSION_1 VERSION_2 LINE LINE_1


while read -r LINE; do
	if $(echo "${LINE}" |grep -q "^${GLOBAL_NAME_OF_PACKAGE}"); then
		NAME_PACKAGE_1="$( echo "${LINE}" |cut -d " " -f 1 )"
		VERSION_1="$( echo "${LINE}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
	fi
	if echo "${LINE}" | grep "<.*@.*>" | grep -q "--" --; then
		DATE_1="$(analyze_date ${LINE})"
	fi
	while read -r LINE_1; do
		if $(echo "${LINE_1}" |grep -q "^${GLOBAL_NAME_OF_PACKAGE}"); then
		NAME_PACKAGE_2="$( echo "${LINE_1}" |cut -d " " -f 1 )"
		VERSION_2="$( echo "${LINE_1}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
		fi
		if echo "${LINE_1}" | grep "<.*@.*>" | grep -q "--" --; then
		DATE_2="$(analyze_date ${LINE_1})"
		fi
		if [ "${NAME_PACKAGE_1}" = "${NAME_PACKAGE_2}" ]; then
			if [ "${VERSION_1}" = "${VERSION_2}" ]; then
				continue
			fi
		#	echo "vers1= ${VERSION_1} DATE_1= ${DATE_1} vers2= ${VERSION_2} DATE_2= ${DATE_2}"
			if dpkg --compare-VERSIONs "${VERSION_1}" gt "${VERSION_2}"; then 
				if [ "${DATE_1}" -gt "${DATE_2}" ]; then 
					continue
				else
					echo "anomaly is among (${NAME_PACKAGE_1} ${VERSION_1}) and (${NAME_PACKAGE_2} ${VERSION_2})"
				fi
			else 
				if [ "${DATE_1}" -lt "${DATE_2}" ]; then
					continue
				else
					echo "anomaly is among (${NAME_PACKAGE_1} ${VERSION_1}) and (${NAME_PACKAGE_2} ${VERSION_2})"
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
print_body ${VER_SORT_TEMP} >2
dell_null_epoch
diff -u ${INPUT_FILE} 2