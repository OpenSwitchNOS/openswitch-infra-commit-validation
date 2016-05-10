#!/bin/bash

# Obtain only git commit message from HEAD, can be multi-line with white spaces
commit_msg=`git log --pretty=format:%s%b -n 1`

# To validate if a commit message has Taiga ID in format TG-XXX
id_state=`echo $commit_msg | grep -i "TG-[0-9].*” | wc -l`

if [ $id_state -ne 0 ]; then
     echo “Taiga ID exists in commit message"
     echo “Valid Commit Message"
     taiga_id=`echo $commit_msg | grep -o -a -m 1 -h -i "TG-[0-9].*" | cut -d' ' -f1 | cut -d'-' -f2 `
     #validate if Taiga ID exists in cvs file
     if [  `cat TaigaALMCompare.csv  | grep ^1618 | wc -l` -eq 1 ]; then
    	 echo “Taiga ID exists in the mapping doc"
     	 taiga_id=`cat TaigaALMCompare.csv  | grep ^$taiga_id | awk -F"," '{print $1}’`
    	 alm_id=`cat TaigaALMCompare.csv  | grep ^$taiga_id | awk -F"," '{print $3}’`
    	 severity=`cat TaigaALMCompare.csv  | grep ^$taiga_id | awk -F"," '{print $5}’`
     	 severity_state=echo $severity | cut -d'-' -f2
     	 feature_name=`cat TaigaALMCompare.csv  | grep ^$taiga_id | awk -F"," '{print $2}’`

      	test $alm_id -ge 0 &> /dev/null
      	if [ $? -gt 1 ]; then
      		echo “A valid ALM Id is not associated with this Taiga ID, Rejecting the commit"
      		exit 1
      	else
      		echo “A valid ALM Id is associated with this Taiga Id"

      		if [ “$severity_state" -eq "High" ] ||  [ “$severity_state" -eq "Medium" ] || [ “$severity_state" -eq “Critical" ]; then
     	    	echo “Severity Level validation complete"
      			echo “Commit message Validation Complete"
      			exit 0
      		else
      			exit 1
      		fi
		fi
	fi
else
    echo “In-valid Commit Message”
    echo “Use git commit - - amend   and submit again"
    exit 1
fi