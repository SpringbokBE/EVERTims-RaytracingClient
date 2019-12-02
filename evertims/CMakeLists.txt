# Specify CMake requirements.
cmake_minimum_required(VERSION 3.12)

set(_SOURCES src/main.cc
             src/reader.cc
             src/reverbEstimate.cc
             src/socket.cc
             src/solver.cc
             src/writer.cc
             src/OSC/OSC-client.c
             src/OSC/OSC-timetag.c)

set(CMAKE_THREAD_PREFER_PTHREAD ON)

# Specify project.
project(evertims
  VERSION 1.0
  DESCRIPTION "C++ Raytracing client"
  LANGUAGES C CXX)

# Specify the executable.
add_executable(evertims ${_SOURCES})

# Specify the dependencies.
add_dependencies(evertims evert::evert Threads::Threads )
find_package(evert REQUIRED)
find_package(Threads)

# Specify the includes.
target_include_directories(evertims
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include/OSC)

# Specify the libraries to link against.
target_link_libraries(evertims
  PRIVATE
    evert::evert
    Threads::Threads
    wsock32
    ws2_32)

target_compile_definitions(evertims
  PRIVATE
    __${CMAKE_SYSTEM_NAME})

target_compile_features(evertims
  PRIVATE
    cxx_std_11)

target_compile_options(evertims
  PRIVATE
    -Wfatal-errors)

install(TARGETS evertims
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin)

include(CMakePackageConfigHelpers)
write_basic_package_version_file("evertimsConfigVersion.cmake"
  VERSION ${evert_VERSION}
  COMPATIBILITY SameMajorVersion)
