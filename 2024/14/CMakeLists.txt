cmake_minimum_required(VERSION 3.16)

project(main VERSION 1.0.0 LANGUAGES C)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(main)

file(GLOB main_files CONFIGURE_DEPENDS "src/**/*.c" "src/*.c")
target_sources(main PRIVATE ${main_files})

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Werror")
    target_link_libraries(main PRIVATE -fsanitize=address)
endif()

target_link_libraries(main PRIVATE -lm)
