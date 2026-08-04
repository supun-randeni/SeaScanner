#!/bin/bash
#************************************************************/
#*    NAME: 	Supun Randeni
#*	  E-MAIL:	supun@mit.edu                                           
#*    ORGN: 	Dept of Mechanical Engineering, MIT, Cambridge MA                                            
#*    FILE: 	rename_project.sh                                        
#*    DATE: 	2024-                                           
#************************************************************/
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
YELLOW=$'\E[1;33m'
NC=$'\e[0m'

if [ -z "$1" ]; then
    echo "usage: ./rename_project.sh {new-project-name}"
    echo
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
pushd "$PROJECT_DIR" >& /dev/null

  PJNAME_NEW="$1"
  PJNAME_ORIGINAL="SeaScanner"
  PJNAME_NEW_UPPERCASE="${PJNAME_NEW^^}"
  PJNAME_ORIGINAL_UPPERCASE="${PJNAME_ORIGINAL^^}"
  
  echo "${RED}Renaming the project name from $PJNAME_ORIGINAL to $1 ${NC}"
  read -r -p "${YELLOW}Are you sure you want to continue? [y/N] ${NC}" response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
      echo "${GREEN}Renaming the project $PJNAME_ORIGINAL to $1 ${NC}"
    
      grep -RIl --exclude-dir=.git -- "$PJNAME_ORIGINAL" . | \
        xargs -r sed -i "s/$PJNAME_ORIGINAL/$PJNAME_NEW/g"
      grep -RIl --exclude-dir=.git -- "SEASCANNER" . | \
        xargs -r sed -i "s/SEASCANNER/$PJNAME_NEW_UPPERCASE/g"
      
  else
      echo "exit"
      exit 1
  fi


popd >& /dev/null

#"${PWD##*/}"
