#!/bin/bash

# set -o errexit
# set -x # delete after debug

USAGE="script.sh CHANGELOG_FILE"

INPUT_FILE=$(find ./debian -name changelog)


# This function takes a list of PACKAGEs which need to print. 
#- This list contain the name of PACKAGEs from INPUT_FILE in special order.




look_for_format_errors(){
while [ -z "$(head -n 1 ${INPUT_FILE})" ]; do
	sed -i "1d" "${INPUT_FILE}"
done
GLOBAL_NAME_OF_PACKAGE="$(head -n 1 ${INPUT_FILE} |cut -d" " -f1|cut -d"-" -f1)"
sed -i "/${GLOBAL_NAME_OF_PACKAGE}.*urgency.*/ s/^ *//" "${INPUT_FILE}"
sed -i "/--.*>/ s/^ */ /" "${INPUT_FILE}"

}

check_epoch(){
if grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" |grep -q ":" ; then
	sed -i "${GLOBAL_NAME_OF_PACKAGE}.*([0-9][^:]/s/(/(0:/g" "${INPUT_FILE}"
fi
}

print_body(){
local LINE_1 LINE NAME VERSION FLAG
local INPUT_ORDER=$1
while IFS= read LINE_1; do
	if $(echo "${LINE_1}" |grep -q "^${GLOBAL_NAME_OF_PACKAGE}"); then
		NAME="$( echo "${LINE_1}" |cut -d " " -f 1 )"
		VERSION="$( echo "${LINE_1}" |cut -d " " -f 2 | sed -e "s/\((\|)\)//g")"
		FLAG=0
	fi
	while IFS= read LINE; do
		if [ "${FLAG}" -eq 1 ]; then
			if echo "${LINE}" | grep "<.*@.*>" | grep -qe "^ -- "; then
				echo "${LINE}"
				echo ""
				break
			fi
			echo "${LINE}"
		fi
		if echo "${LINE}" | grep -q "${NAME}" && echo "${LINE}" | grep -q "${VERSION}"; then
			echo "${LINE}"
			FLAG=1
		fi
	done<${INPUT_FILE}
done<${INPUT_ORDER}
}


sort_by_version(){

TEMP_BUFFER=$(mktemp -t TEMP_BUFFER.XXXXX)
MY_VER_SORT_TEMP=$(mktemp -t MY_VER_SORT_TEMP.XXXXX)
SORTING_ORDER_INPUT_FILE=$(mktemp -t SORTING_ORDER_INPUT_FILE.XXXXX)
DIFF_FILE=$(mktemp -t DIFF_FILE.XXXXX)
echo "$(grep "^${GLOBAL_NAME_OF_PACKAGE}" "${INPUT_FILE}" | cut -d " " -f 1,2 | sort -ru| sed -e "s/\((\|)\)//g")" > "${MY_VER_SORT_TEMP}"
dpkg-parsechangelog --show-field version --all --format rfc822| sed '/^$/d' > "${SORTING_ORDER_INPUT_FILE}"
diff -u "${SORTING_ORDER_INPUT_FILE}" <(cut -d" " -f2 "${MY_VER_SORT_TEMP}") > "${DIFF_FILE}"
if [ -s ${DIFF_FILE} ]; then
	echo "${INPUT_FILE} has problem whith sorting package version"
	cat ${DIFF_FILE}
fi
print_body "${MY_VER_SORT_TEMP}" > "${TEMP_BUFFER}"
cp "${TEMP_BUFFER}" "${INPUT_FILE}"
# rm -rf "${MY_VER_SORT_TEMP}" "${SORTING_ORDER_INPUT_FILE}" "${TEMP_BUFFER}" "${DIFF_FILE}"
echo "${MY_VER_SORT_TEMP}" "${SORTING_ORDER_INPUT_FILE}" "${TEMP_BUFFER}" "${DIFF_FILE}"

}


look_for_anomalies(){

local DATE_1 DATE_2 VERSION_1 VERSION_2 LINE LINE_1

i=0
j=0
while read true ; do
	i=$((i + 1))
	if dpkg-parsechangelog -o $i -c 1 --show-field source --format rfc822 &>/dev/null ; then
		break
	fi
	VERSION_1="$(dpkg-parsechangelog -n $i --show-field version --format rfc822)"
	DATE_1="$(dpkg-parsechangelog -n $i --show-field date --format rfc822)"
	while read true; do
		j=$((i + 1))
		if dpkg-parsechangelog -o $j -c 1 --show-field source --format rfc822 &>/dev/null ; then
			break
		fi
		VERSION_2="$(dpkg-parsechangelog -n $j --show-field version --format rfc822)"
		DATE_2="$(dpkg-parsechangelog -n $j --show-field date --format rfc822)"
		if dpkg --compare-versions "${VERSION_1}" gt "${VERSION_2}" ; then
			if [ `date -d ${DATE_1} +%s` -gt `date -d ${DATE_2} +%s` ]; then
				continue
			else
				echo "anomaly is in a date between :"
				echo "${VERSION_1} ${DATE_1} and ${VERSION_2} ${DATE_2}"
				exit 1
			fi
		elif dpkg --compare-versions "${VERSION_1%~*}" ge "${VERSION_2}" ; then
			if [ `date -d ${DATE_1} +%s` -gt `date -d ${DATE_2} +%s` ]; then
				continue
			else
				echo "anomaly is in a date between :"
				echo "${VERSION_1} ${DATE_1} and ${VERSION_2} ${DATE_2}"
				exit 1
			fi
		fi
		done<${INPUT_FILE}
done<${INPUT_FILE}

}


dell_null_epoch(){

sed -i "/^${GLOBAL_NAME_OF_PACKAGE}.*(0:/s/(0:/(/g" "${INPUT_FILE}"

}

# the logic of script

look_for_format_errors
check_epoch
sort_by_version
look_for_anomalies
dell_null_epoch
