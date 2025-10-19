cmake_minimum_required(VERSION 3.13...3.27)

# initialise SDK and set PICO_SDK_PATH
include(/home/pitchu/code/pico-sdk/pico_sdk_init.cmake)

set(project_name $ENV{PROJECT_NAME})
project(${project_name})

# initialize the Raspberry Pi Pico SDK
pico_sdk_init()

add_executable(${project_name}
    main.c
)

target_link_libraries(${project_name} pico_stdlib)
pico_add_extra_outputs(${project_name})
