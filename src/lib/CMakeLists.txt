#************************************************************/
#*    NAME: 	Supun Randeni
#*    E-MAIL:	supun@mit.edu                                           
#*    ORGN: 	Dept of Mechanical Engineering, MIT, Cambridge MA                                            
#*    FILE: 	SeaScanner/src/lib/CMakeLists.txt                                     
#*    DATE: 	2024-
#*    INFO:                                         
#************************************************************/


## copy headers to /include
file(GLOB_RECURSE INCLUDE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.h *.proto *.hpp)
foreach(I ${INCLUDE_FILES})
  configure_file(${I} ${SEASCANNER_INC_DIR}/${I} @ONLY)
endforeach()

#============================================================================
# Add the libraries in the current directory to the include path
#============================================================================
FILE(GLOB SEASCANNER_LIB_DIR ./lib_*)
INCLUDE_DIRECTORIES(${SEASCANNER_LIB_DIR})

#============================================================================
# List the subdirectories to build...
#============================================================================
# Lib
#ADD_SUBDIRECTORY(xxx)


##############################################################################
#                           END of CMakeLists.txt
##############################################################################

