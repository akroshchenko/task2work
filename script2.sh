#!/bin/bash

usage="script2.sh (sort|find) (version|date|vd|anom|error) name_input_file [name_output_file]"



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
