#!/bin/bash
#************************************************************/
#*    NAME: 	Supun Randeni
#*    E-MAIL:	supun@mit.edu                                           
#*    ORGN: 	Dept of Mechanical Engineering, MIT, Cambridge MA                                            
#*    FILE: 	SeaScanner/build.sh                                         
#*    DATE: 	2023-08-21
#*    INFO:                                               
#************************************************************/

GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
YELLOW=$'\E[1;33m'
NC=$'\e[0m'

INVOCATION_ABS_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_TYPE="None"
SEASCANNER_CMAKE_FLAGS=$SEASCANNER_CMAKE_FLAGS" "-Dcompile_doc=OFF 
SEASCANNER_CMAKE_FLAGS=$SEASCANNER_CMAKE_FLAGS" "-Duse_moosivp_package=OFF

#-------------------------------------------------------------------
#  Check for and handle command-line arguments
#-------------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
	printf "%s [SWITCHES]                                              \n" $0
	printf "Switches:                                                  \n" 
	printf "  --help,    -h                                            \n" 
  printf "  --debug,   -d                                            \n"
  printf "  --release, -r                                            \n"
  printf "  --ivp_source                                             \n"
  printf "  --ivp_package                                            \n"
  printf "  --build_doc : Compiles documentation                     \n"
	printf "Notes:                                                     \n"
	printf " (1) All other command line args will be passed as args    \n"
	printf "     to \"make\" when it is eventually invoked.            \n"
	printf " (2) For example -k will continue making when/if a failure \n"
	printf "     is encountered in building one of the subdirectories. \n"
	printf " (3) For example -j2 will utilize a 2nd core in the build  \n"
	printf "     if your machine has two cores. -j4 etc for quad core. \n"
	exit 0;
    elif [ "${ARGI}" = "--debug" -o "${ARGI}" = "-d" ] ; then
        BUILD_TYPE="Debug"
    elif [ "${ARGI}" = "--release" -o "${ARGI}" = "-r" ] ; then
        BUILD_TYPE="Release"
    elif [ "${ARGI}" = "--ivp_source" ] ; then
        SEASCANNER_CMAKE_FLAGS=$SEASCANNER_CMAKE_FLAGS" "-Duse_moosivp_package=OFF
    elif [ "${ARGI}" = "--ivp_package" ] ; then
        SEASCANNER_CMAKE_FLAGS=$SEASCANNER_CMAKE_FLAGS" "-Duse_moosivp_package=ON
    elif [ "${ARGI}" = "--build_doc" ] ; then
        SEASCANNER_CMAKE_FLAGS=$SEASCANNER_CMAKE_FLAGS" "-Dcompile_doc=ON
    else
	CMD_LINE_ARGS=$CMD_LINE_ARGS" "$ARGI
    fi
done

BUILD_TYPE=$BUILD_TYPE" "$SEASCANNER_CMAKE_FLAGS

#-------------------------------------------------------------------
#  Build MITFrontseat first
#-------------------------------------------------------------------

# check if MITFrontseat repo exists, then call the build
pushd "$SCRIPT_DIR/.." >& /dev/null
if [ -e MITFrontseat-drivers ]; then
  echo "Found MITFrontseat-drivers"
  pushd MITFrontseat-drivers >& /dev/null
  echo "${GREEN}   === Calling MITFrontseat-drivers' build.sh script === ${NC}"
  ./build.sh $@
  popd >& /dev/null
elif [ -e StackUxV-drivers ]; then
  echo "Found StackUxV-drivers"
  pushd StackUxV-drivers >& /dev/null
  echo "${GREEN}   === Calling StackUxV-drivers' build.sh script === ${NC}"
  ./build.sh $@
  popd >& /dev/null
else 
  echo "${RED}   === WARNING! StackUxV-drivers or MITFrontseat-drivers not found === ${NC}"
fi
popd >& /dev/null

#-------------------------------------------------------------------
#  Part 2: Invoke the call to make in the build directory
#-------------------------------------------------------------------
echo "${GREEN}   === Building SeaScanner ===${NC}"

#-------------------------------------------------------------------
#  Part 2.1: Build external projects with MakeFiles

echo "${GREEN}   -- Building SeaScanner libraries and apps --${NC}"
mkdir -p build
cd "$SCRIPT_DIR/build"

cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ../

make ${CMD_LINE_ARGS}
cd ${INVOCATION_ABS_DIR}
