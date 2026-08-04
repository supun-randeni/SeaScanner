#************************************************************/
#*    NAME: 	Supun Randeni
#*    E-MAIL:	supun@mit.edu                                           
#*    ORGN: 	Dept of Mechanical Engineering, MIT, Cambridge MA                                            
#*    FILE: 	SeaScanner/CMakeLists.txt                                     
#*    DATE: 	2024-
#*    INFO:                                         
#************************************************************/

#============================================================================
# Add the libraries in the current directory to the include path
#============================================================================
FILE(GLOB SEASCANNER_LIB_DIR ./lib_*)
INCLUDE_DIRECTORIES(${SEASCANNER_LIB_DIR})

#============================================================================
# List the subdirectories to build...
#============================================================================
ADD_SUBDIRECTORY(lib)

# MOOS Apps
ADD_SUBDIRECTORY(moos)

# Daemon programs
ADD_SUBDIRECTORY(daemon)


#============================================================================
# Build documentation if configured to do so..
#============================================================================
if (compile_doc)
  #ADD_SUBDIRECTORY(doc)
endif()


##############################################################################
#                           END of CMakeLists.txt
##############################################################################

