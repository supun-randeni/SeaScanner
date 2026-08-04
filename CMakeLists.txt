#************************************************************/
#*    NAME: 	Supun Randeni
#*    E-MAIL:	supun@mit.edu                                           
#*    ORGN: 	Dept of Mechanical Engineering, MIT, Cambridge MA                                            
#*    FILE: 	Top-level CMakeLists.txt file for SeaScanner
#*    DATE: 	2023-08-21
#*    INFO:                                         
#************************************************************/

CMAKE_MINIMUM_REQUIRED(VERSION 3.3)
PROJECT(SEASCANNER)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake_modules/")

set (CMAKE_CXX_STANDARD 11)

#=======================================================================
# Set the output directories for the binary and library files
#=======================================================================

GET_FILENAME_COMPONENT(SEASCANNER_BIN_DIR "${CMAKE_SOURCE_DIR}/bin"  ABSOLUTE )
GET_FILENAME_COMPONENT(SEASCANNER_LIB_DIR "${CMAKE_SOURCE_DIR}/lib"  ABSOLUTE )
GET_FILENAME_COMPONENT(SEASCANNER_LIB_SRC_DIR "${CMAKE_SOURCE_DIR}/src/lib"  ABSOLUTE )
GET_FILENAME_COMPONENT(SEASCANNER_INC_DIR "${CMAKE_SOURCE_DIR}/include" ABSOLUTE)
GET_FILENAME_COMPONENT(SEASCANNER_PARENT_DIR .. ABSOLUTE)

SET( LIBRARY_OUTPUT_PATH      "${SEASCANNER_LIB_DIR}" CACHE PATH "" )
SET( ARCHIVE_OUTPUT_DIRECTORY "${SEASCANNER_LIB_DIR}" CACHE PATH "" )
SET( LIBRARY_OUTPUT_DIRECTORY "${SEASCANNER_LIB_DIR}" CACHE PATH "" )

SET( EXECUTABLE_OUTPUT_PATH    "${SEASCANNER_BIN_DIR}" CACHE PATH "" )
SET( RUNTIME_OUTPUT_DIRECTORY "${SEASCANNER_BIN_DIR}"  CACHE PATH "" )

include_directories(${SEASCANNER_INC_DIR})

#=======================================================================
# Find Protocol buffers
#=======================================================================

# protocol buffers - http://code.google.com/apis/protocolbuffers/
find_package(ProtobufLocal REQUIRED)
include_directories(${PROTOBUF_INCLUDE_DIRS})

if(${PROTOC_VERSION} VERSION_LESS 2.5.0})
  message("libprotobuf < 2.5.0")
else()
  message("libprotobuf >= 2.5.0")
  set(PROTOBUF_ALLOW_ALIAS "option allow_alias = true;")
endif()

#=======================================================================
# Find MOOS
#=======================================================================
find_package(MOOS 10.0)
INCLUDE_DIRECTORIES(${MOOS_INCLUDE_DIRS})


#=======================================================================
# Find the "moos-ivp" 
#=======================================================================

# Search for the moos-ivp folder
find_path( MOOSIVP_SOURCE_TREE_BASE
   NAMES build-ivp.sh build-moos.sh configure-ivp.sh
   PATHS "../moos-ivp" "../../moos-ivp" "../../moos-ivp/trunk/" "../moos-ivp/trunk/"
   DOC "Base directory of the MOOS-IvP source tree"
   NO_DEFAULT_PATH
)

if (use_moosivp_package)
   message("Using moos-ivp package")
   find_package(IvP REQUIRED)
   include_directories(${IVP_INCLUDE_DIRS})

elseif (MOOSIVP_SOURCE_TREE_BASE)

   message("Found moos-ivp source at:" ${MOOSIVP_SOURCE_TREE_BASE})
   message("Using moos-ivp from source")

   FILE(GLOB IVP_INCLUDE_DIRS ${MOOSIVP_SOURCE_TREE_BASE}/ivp/src/lib_* )
   INCLUDE_DIRECTORIES(${IVP_INCLUDE_DIRS})

   FILE(GLOB IVP_LIBRARY_DIRS ${MOOSIVP_SOURCE_TREE_BASE}/lib )
   LINK_DIRECTORIES(${IVP_LIBRARY_DIRS})

else()
   message("moos-ivp source not found.")
endif()

#=======================================================================
# Find the "Boost" 
#=======================================================================

# boost - http://www.boost.org/
find_package(Boost 1.55.0 REQUIRED date_time thread system program_options filesystem regex serialization)
include_directories(${Boost_INCLUDE_DIRS})

#======================================================================
# Specify where to find MITFrontseat's headers and libraries...
#======================================================================
IF( EXISTS ${SEASCANNER_PARENT_DIR}/MITFrontseat)
   # Specify where to find MITFrontseat's headers and libraries...
   get_filename_component(MITFrontseat_INC_DIR  ${SEASCANNER_PARENT_DIR}/MITFrontseat/include ABSOLUTE)
   get_filename_component(MITFrontseat_LIB_DIR  ${SEASCANNER_PARENT_DIR}/MITFrontseat/lib ABSOLUTE)
   include_directories(${MITFrontseat_INC_DIR})
   LINK_DIRECTORIES(${MITFrontseat_LIB_DIR})
   protobuf_include_dirs(${MITFrontseat_INC_DIR})
   message ("Found MITFrontseat in ${MITFrontseat_INC_DIR}")  
   
elseif( EXISTS ${SEASCANNER_PARENT_DIR}/StackUxV)
  # Specify where to find StackUxV's headers and libraries...
  get_filename_component(MITFrontseat_INC_DIR  ${SEASCANNER_PARENT_DIR}/StackUxV/include ABSOLUTE)
  get_filename_component(MITFrontseat_LIB_DIR  ${SEASCANNER_PARENT_DIR}/StackUxV/lib ABSOLUTE)
  include_directories(${MITFrontseat_INC_DIR})
  LINK_DIRECTORIES(${MITFrontseat_LIB_DIR})
  protobuf_include_dirs(${MITFrontseat_INC_DIR})
  message ("Found StackUxV in ${MITFrontseat_INC_DIR}") 
ENDIF()

#======================================================================
# Specify Compiler Flags
#======================================================================
IF( ${WIN32} )
   #---------------------------------------------
   # Windows Compiler Flags
   #---------------------------------------------
   IF(MSVC)
      # Flags for Microsoft Visual Studio
      SET( WALL_ON OFF CACHE BOOL 
         "tell me about all compiler warnings (-Wall) ")
      IF(WALL_ON)
         SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
      ENDIF(WALL_ON)
   ELSE(MSVC)
      # Other Windows compilers go here
   ENDIF(MSVC)

ELSE( ${WIN32} )
   #---------------------------------------------
   # Linux and Apple Compiler Flags
   #---------------------------------------------
   # Force -fPIC because gcc complains when we don't use it with x86_64 code.
   # Note sure why: -fPIC should only be needed for shared objects, and
   # AFAIK, CMake gets that right when building shared objects. -CJC
   SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -g -Wdeprecated-declarations")
   IF(CMAKE_COMPILER_IS_GNUCXX)
      # Flags for the GNU C++ Compiler
      SET( WALL_ON OFF CACHE BOOL 
         "tell me about all compiler warnings (-Wall) ")
      IF(WALL_ON)
         SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall" -C++11)
      ENDIF( WALL_ON)
   ELSE(CMAKE_COMPILER_IS_GNUCXX)
    
   ENDIF(CMAKE_COMPILER_IS_GNUCXX)

ENDIF( ${WIN32} )

#=======================================================================
# Add Subdirectories
#=======================================================================
ADD_SUBDIRECTORY( src )
