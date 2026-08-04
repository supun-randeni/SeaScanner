#!/bin/bash
#************************************************************/
#*    NAME: 	Supun Randeni
#*	  E-MAIL:	supun@mit.edu                                           
#*    ORGN: 	Dept of Mechanical Engineering, MIT, Cambridge MA                                            
#*    FILE: 	clean_stackuxv-extend.sh                                        
#*    DATE: 	2023-08-21                                            
#************************************************************/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

find "$PROJECT_DIR/build" -mindepth 1 -delete 2>/dev/null || true
find "$PROJECT_DIR/lib" -mindepth 1 -delete 2>/dev/null || true
find "$PROJECT_DIR/include" -mindepth 1 -delete 2>/dev/null || true
find "$PROJECT_DIR/bin" -mindepth 1 -delete 2>/dev/null || true
rm -f "$PROJECT_DIR/.DS_Store"

find "$PROJECT_DIR" -name '.DS_Store' -print -delete
find "$PROJECT_DIR" -name '*~' -print -delete
find "$PROJECT_DIR" -name '#*' -print -delete
find "$PROJECT_DIR" -name '*.moos++' -print -delete

find "$PROJECT_DIR" -name 'MOOSLog_*' -print -delete

find "$PROJECT_DIR" -name '*.a' -print -delete
find "$PROJECT_DIR" -name '*.o' -print -delete
find "$PROJECT_DIR" -name '*.d' -print -delete
find "$PROJECT_DIR" -name '*.dpp' -print -delete
