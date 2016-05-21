#!/bin/bash

# set -o errexit
# set -x # delete after debug

USAGE="script.sh CHANGELOG_FILE"

INPUT_FILE="${1}"

if [ -z "$(head -n 1 ${INPUT_FILE})" ];then
	echo "File ${INPUT_FILE} contains empty first LINE"
	exit 1
fi

GLOBAL_NAME_OF_PACKAGE="$(head -n 1 ${INPUT_FILE} |cut -d" " -f1|cut -d"-" -f1)"

# This function takes a list of PACKAGEs which need to print. 
#- This list contain the name of PACKAGEs from INPUT_FILE in special order.
print_body(){

local INPUT_ORDER=$1
local NAME VERSION LINE_1 FLAG

while read -r LINE_1; do
	if $(echo "${LINE_1}" |grep -q "^${GLOBAL_NAME_OF_PACKAGE}"); then
		NAME="$( echo "${LINE_1}" |cut -d " " -f 1 )"
		VERSION="$( echo "${LINE_1}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
		FLAG=0
	fi
	while read -r LINE; do
		if [ ${FLAG} -eq 1 ]; then
			if echo "${LINE}" | grep "<.*@.*>" | grep -e "^ -- " --; then
				echo -e "${LINE}"
				echo ""
				break
			fi
			echo -e "${LINE}"
		fi
		if echo "${LINE}" | grep -q "${NAME}" && echo "${LINE}" | grep -q "${VERSION}"; then
			echo -e "${LINE}"
			FLAG=1
		fi
	done<${INPUT_FILE}
done<${INPUT_ORDER}

}


sort_by_version(){

VER_SORT_TEMP=$(mktemp -t VER_SORT_TEMP.XXXXX)
echo "$(grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" | cut -d " " -f 1,2 | sort -k 2,2r)" >${VER_SORT_TEMP}
echo "List of the PACKAGEs sorting by version store in ${VER_SORT_TEMP}"

}


analyze_date(){
local INPUT_LINE=$1
local YEAR MONTH DAY YEAR HOUR EXTRA_HOUR MINUTE EXTRA_MINUTE SEC REAL_MINUTE REAL_HOUR

# PREPARED_LINE="$(echo "${INPUT_LINE}"| tr -s [:blank:] | grep -Ew "(Sun,|Mon,|Tue,|Wed,|Thu,|Fri,|Sat).*" | cut -d " " -f 6- )"
PREPARED_LINE="$(echo "${INPUT_LINE}" | awk '{for(i=4;i>=0;i--) printf("%s%s",$(NF-i),OFS)}')"
		YEAR="$(echo "${PREPARED_LINE}" | cut -d " " -f 3)"
		MONTH="$(echo "${PREPARED_LINE}" | cut -d " " -f 2)"
		DAY="$(echo "${PREPARED_LINE}" | cut -d " " -f 1)"
		# DAY=${DAY#0}
		HOUR="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 1)"
		# HOUR=${HOUR#0}
		EXTRA_HOUR="$(echo "${PREPARED_LINE}" | cut -d " " -f 5 | cut -c 1,2,3 |sed 's/+//')"
		# EXTRA_HOUR=${EXTRA_HOUR#0}
		MINUTE="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 2)"
		# MINUTE=${MINUTE#0}
		EXTRA_MINUTE="$(echo "${PREPARED_LINE}" | cut -d " " -f 5 | cut -c 1,4,5 |sed 's/+//')"
		# EXTRA_MINUTE=${EXTRA_MINUTE#0}
		SEC="$(echo "${PREPARED_LINE}" | cut -d " " -f 4 | cut -d ":" -f 3)"
		if [ ${REAL_MINUTE=$(expr ${MINUTE} - ${EXTRA_MINUTE})} -ge 60 ]; then 
			HOUR=$(expr $HOUR +1 )
			REAL_MINUTE=$(expr $REAL_MINUTE - 60)
		elif [ ${REAL_MINUTE} -lt 0 ]; then 
			HOUR=$(expr $HOUR - 1 )
			REAL_MINUTEE=$(expr $REAL_MINUTE + 60)
		fi

		if [ ${REAL_HOUR=$(expr $HOUR - $EXTRA_HOUR)} -ge 24 ]; then
			DAY=$(expr $DAY +1)
			REAL_HOUR=$(expr $REAL_HOUR - 24)
		elif [ ${REAL_HOUR#0} -lt 0 ]; then
			DAY=$(expr $DAY - 1)
			REAL_HOUR=$(expr $REAL_HOUR + 24)
		fi

		if [ $((YEAR % 4)) -eq 0 -a $((YEAR%100)) -ne 0 ]; then 
			VISOC_YEAR=1
			if [ "${MONTH}" = "Feb" ]; then 
				if [ $(DAY) -qt 29 ]; then 
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
				if [ "${DAY}" -gt 31 ]; then			
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
				if [ "${DAY}" -gt 31 ]; then
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
				if [ "${DAY}" -gt 31 ]; then
					DAY=$((DAY - 31))
					MONTH=Aug
				fi

				if [ "${DAY}" -le 0 ]; then
					DAY=30
					MONTH=Jun
				fi
				;;
			Aug)
				if [ "${DAY}" -gt 31 ]; then
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
N_MONTH="$(echo ${MONTH} |sed -e s/Jan/1/g -e s/Feb/2/g \
	-e s/Mar/3/g -e s/Apr/4/g -e s/May/5/g -e s/Jun/6/g \
	-e s/Jul/7/g -e s/Aug/8/g -e s/Sep/9/g -e s/Oct/10/g \
	-e s/Nov/11/g -e s/Dec/12/g)"

echo "${YEAR}$(expr ${N_MONTH} \* 50000 + ${DAY} \* 24 \* 60 + ${REAL_HOUR} \* 60 + ${REAL_MINUTE})"

}

looking_for_anomalies(){

local DATE_1 DATE_2 NAME_PACKAGE_1 NAME_PACKAGE_2 VERSION_1 VERSION_2 LINE LINE_1


while read -r LINE; do
	if echo "${LINE}" |grep -q "^${GLOBAL_NAME_OF_PACKAGE}"; then
		NAME_PACKAGE_1="$( echo "${LINE}" |cut -d " " -f 1 )"
		VERSION_1="$( echo "${LINE}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
	fi
	if echo "${LINE}" | grep "<.*@.*>" | grep -q "--" -- ; then
		DATE_1=$(analyze_date "${LINE}")
		while read -r LINE_1; do
			if echo "${LINE_1}" |grep -q "^${GLOBAL_NAME_OF_PACKAGE}"; then
				NAME_PACKAGE_2="$( echo "${LINE_1}" |cut -d " " -f 1 )"
				VERSION_2="$( echo "${LINE_1}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
				continue
			fi
			if echo "${LINE_1}" | grep "<.*@.*>" | grep -q "--" -- ; then
				DATE_2=$(analyze_date "${LINE_1}")
				if [ "${NAME_PACKAGE_1}" = "${NAME_PACKAGE_2}" ]; then
					if [ "${VERSION_1}" = "${VERSION_2}" ]; then
						continue
					fi
					if dpkg --compare-versions "${VERSION_1}" gt "${VERSION_2}" ; then 
						if echo "${VERSION_2}" |grep -q "mos" && echo "${VERSION_1}" |grep -vq "mos"; then
							if [ "${DATE_1}" -lt "${DATE_2}" ]; then
								continue
							else 
								echo "anomaly is in a date among :"
								echo "${NAME_PACKAGE_1} ${VERSION_1} ${DATE_1}"
								echo "${NAME_PACKAGE_2} ${VERSION_2} ${DATE_2}"
								exit 1
							fi
						fi
						if [ "${DATE_1}" -gt "${DATE_2}" ]; then
							continue
						else
							echo "anomaly is in a date among :"
							echo "${NAME_PACKAGE_1} ${VERSION_1} ${DATE_1}"
							echo "${NAME_PACKAGE_2} ${VERSION_2} ${DATE_2}"
							exit 1
						fi
					elif echo "${VERSION_1}" |grep -q "mos" && echo "${VERSION_2}" |grep -vq "mos"; then
						if [ "${DATE_1}" -gt "${DATE_2}" ]; then
							continue
						else 
							echo "anomaly is in a date among :"
							echo "${NAME_PACKAGE_1} ${VERSION_1} ${DATE_1}"
							echo "${NAME_PACKAGE_2} ${VERSION_2} ${DATE_2}"
							exit 1
						fi
					fi
				fi
			fi
			continue
		done<${INPUT_FILE}
	fi
done<${INPUT_FILE}

}


check_epoch(){

if grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" |grep -q ":" ; then
	sed -i "${GLOBAL_NAME_OF_PACKAGE}.*([0-9][^:]/s/(/(0:/g" "${INPUT_FILE}"
	echo "EPOCH PRESENT"
fi

}


dell_null_epoch(){
echo "${GLOBAL_NAME_OF_PACKAGE}"
sed -i "${GLOBAL_NAME_OF_PACKAGE}.*\(0:/s/\(0:/\(/g" "${INPUT_FILE}"

}

looking_for_format_errors(){

FORMATING_ERROR=$(mktemp -t FORMATING_ERROR.XXXXX)

echo -E "Looking for the format errors =====>"
grep -E "^${GLOBAL_NAME_OF_PACKAGE}.*\(.*\).*" "${INPUT_FILE}" | \
grep -Ev "^${GLOBAL_NAME_OF_PACKAGE}.*[[:space:]]{1}\(([0-9]:)?[0-9\.[0-9]\..*" >>${FORMATING_ERROR} || true #debug

grep -E "^[[:space:]]+${GLOBAL_NAME_OF_PACKAGE}.* \(.*\)" "${INPUT_FILE}" >>${FORMATING_ERROR} || true

grep -E "^[[:space:]]*--.*>[[:space:]]*(Mon, |Tue, |Wed, |Thu, |Fri, |Sat, |Sun)" \
 "${INPUT_FILE}" |grep -vE "^[[:space:]]{1}--.*>[[:space:]]{2}(Mon, |Tue, |Wed, |Thu, |Fri, |Sat, |Sun)" >>${FORMATING_ERROR} ||true
 if [ -s ${FORMATING_ERROR} ]; then
 	echo "Correct next formating errors:"
 	cat ${FORMATING_ERROR}
 else
 	echo "Nothing to fix"
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
# diff -u ${INPUT_FILE} 2