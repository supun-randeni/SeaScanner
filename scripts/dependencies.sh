#!/bin/bash
#************************************************************/
#*    NAME: 	Supun Randeni
#*    E-MAIL:	supun@mit.edu                                           
#*    ORGN: 	Dept of Mechanical Engineering, MIT, Cambridge MA                                            
#*    FILE: 	SeaScanner/dependencies.sh                                         
#*    DATE: 	2023-08-21
#*    INFO:   Adopted from LAMSS                                               
#************************************************************/

if [[ $UID -ne 0 ]]; then
    printf "You must run this script as root. Use 'sudo' in Ubuntu. \n" 1>&2
    exit 1
fi

if [[ `lsb_release -is` != "Debian" ]]; then
	if [[ `lsb_release -is` != "Ubuntu" ]]; then
		if [[ `lsb_release -is` != "Raspbian" ]]; then
			printf "This script only works on Ubuntu and Debian. Please examine the DEPENDENCIES file as a starting point for finding the required packages on your distribution"
			exit 1
		fi
	fi
fi

echo "Installing librobotcontrol.."
if [[ $(arch) = "x86_64" ]]; then
  dpkg -i librobotcontrol_1.0.4_amd64.deb
fi


make -j1 -f DEPENDENCIES -- `lsb_release -cs` "$@"

echo "Done with DEPENDENCIES"

