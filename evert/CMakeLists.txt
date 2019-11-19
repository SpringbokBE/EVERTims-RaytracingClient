# Specify CMake requirements.
cmake_minimum_required(VERSION 3.1...3.15)

if(${CMAKE_VERSION} VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

# Specify project.
project(evert
  VERSION 1.0
  DESCRIPTION "C++ Raytracing routines"
  LANGUAGES CXX
  )

# Specify the library.
add_library(evert
  SHARED
    src/elBeam.cc
    src/elBSP.cc
    src/elListener.cc
    src/elMaterial.cc
    src/elOrientedPoint.cc
    src/elPathSolution.cc
    src/elPolygon.cc
    src/elRoom.cc
    src/elSource.cc
    src/elVector.cc
  )

# Specify the dependencies.
add_dependencies(evert OpenGL::GL OpenGL::GLU)
find_package(OpenGL REQUIRED)

# Specify the includes.
target_include_directories(evert
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
  )

# Specify the libraries to link against.
target_link_libraries(evert
  PRIVATE
    OpenGL::GL
    OpenGL::GLU
  )

target_compile_options(evert PRIVATE -Wall)

# Still to be modified below this line.

add_definitions ("-D__${CMAKE_SYSTEM_NAME}")

file (WRITE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}Config.cmake
"\
set (evert_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include/evert)
set (evert_LIBRARIES ${CMAKE_INSTALL_PREFIX}/lib/libevert${CMAKE_SHARED_LIBRARY_SUFFIX})")

install(
    TARGETS ${PROJECT}
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/ DESTINATION include/${PROJECT}
    FILES_MATCHING PATTERN "*.h")

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}Config.cmake
    DESTINATION lib/cmake/${PROJECT})
