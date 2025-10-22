cmake_minimum_required(VERSION 3.13...3.27)

# initialise SDK and set PICO_SDK_PATH
include(/home/pitchu/code/pico-sdk/pico_sdk_init.cmake)

set(project_name $ENV{PROJECT_NAME})
project(${project_name})

# initialize the Raspberry Pi Pico SDK
pico_sdk_init()

add_executable(${project_name}
    blink.c
)

target_link_libraries(${project_name} pico_stdlib)

# enable usb
pico_enable_stdio_usb(${project_name} 1)
pico_enable_stdio_uart(${project_name} 0)

pico_add_extra_outputs(${project_name})
