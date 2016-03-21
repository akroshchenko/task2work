#!/bin/bash

usage="script2.sh (sort|find) (version|date|vd|anom|error) name_input_file "

input_file=$3
name_of_package=mysql

print_body() {

local name=$(cut -d " " -f 1 <(echo $2))
local version=$(cut -d " " -f 2 <(echo $2))
echo "start printbody"
flag=0
while read -r line
do
if [ ${flag} ]
then
	if [[ $line =~ ^.*--  ]]
	then 
		echo "$line"
		break
	fi
echo "$line"
fi

if [[ $line =~ .*${name}.*${version} ]]
then
echo "$line"
flag=1 
fi
done<${input_file}
echo "end of print body"
return 0
}

sort_by_version(){
old_IFS=${IFS}
echo "start of sort and"



#IFS=$'\n'
for print_package in "$( grep "^${name_of_package}" ${input_file} | cut -d " " -f 2 |sort -r -k 2,2 | tr '\n' ' ')"
do
	IFS=$old_IFS
	print_body input_file "${print_package}"

done
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


