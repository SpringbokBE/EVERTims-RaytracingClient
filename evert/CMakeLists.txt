# Specify CMake requirements.
cmake_minimum_required(VERSION 3.12)

set(_SOURCES src/elBeam.cc
             src/elBSP.cc
             src/elListener.cc
             src/elMaterial.cc
             src/elOrientedPoint.cc
             src/elPathSolution.cc
             src/elPolygon.cc
             src/elRoom.cc
             src/elSource.cc
             src/elVector.cc)

set(_HEADERS include/elAABB.h
             include/elBeam.h
             include/elBSP.h
             include/elDefs.h
             include/elListener.h
             include/elMaterial.h
             include/elOrientedPoint.h
             include/elPathSolution.h
             include/elPolygon.h
             include/elRay.h
             include/elRoom.h
             include/elSource.h
             include/elVector.h)

# Specify project.
project(evert
  VERSION 1.0
  DESCRIPTION "C++ Raytracing routines"
  LANGUAGES CXX)

# Specify the library.
add_library(evert
  SHARED ${_SOURCES})

# Specify the dependencies.
add_dependencies(evert OpenGL::GL OpenGL::GLU)
find_package(OpenGL REQUIRED)

# Specify the includes.
target_include_directories(evert
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)

# Specify the libraries to link against.
target_link_libraries(evert
  PRIVATE
    OpenGL::GL
    OpenGL::GLU)

# target_compile_options(evert
#   PRIVATE
#     -Wall)

target_compile_definitions(evert PRIVATE __${CMAKE_SYSTEM_NAME})

set_target_properties(evert
  PROPERTIES
    PUBLIC_HEADER "${_HEADERS}")

install(TARGETS evert EXPORT evertTargets
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include)

install(EXPORT evertTargets
  FILE evertTargets.cmake
  NAMESPACE evert::
  DESTINATION lib/cmake/evert)

include(CMakePackageConfigHelpers)
write_basic_package_version_file("evertConfigVersion.cmake"
  VERSION ${evert_VERSION}
  COMPATIBILITY SameMajorVersion)

install(FILES "evertConfig.cmake" "${CMAKE_CURRENT_BINARY_DIR}/evertConfigVersion.cmake"
  DESTINATION lib/cmake/evert)
