#!/bin/bash

usage="script2.sh (sort|find) (version|date|vd|anom|error) name_input_file [name_output_file]"

print_body(){



local name=$(cut -d " " -f 1 <(echo $2))
local version=$(cut -d " " -f 2 <(echo $2))



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
done<"$1"
return 0
}

print_body $1 "mysql (3.20.32a-4)" 
exit 0
case $1 in
	sort)
		case $2 in
			version) 
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


