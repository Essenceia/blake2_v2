BUILD_DIR:=artifact
PROJECT_NAME:=blake2s_asic_firmeware
SRC:=$(wildcard *.c) $(wildcard *.h) $(wildcard *.pio)

${BUILD_DIR}: CMakeLists.txt
	PROJECT_NAME=${PROJECT_NAME} cmake -S . ${BUILD_DIR}

.PHONY: setup build flash

setup: ${BUILD_DIR}

build: setup ${SRC}
	PROJECT_NAME=${PROJECT_NAME} cmake --build ${BUILD_DIR} --target ${PROJECT_NAME}
	
flash:
	sudo cp ${BUILD_DIR}/${PROJECT_NAME}.uf2 /mnt/rpi

# using default baudrate
serial:
	picocom -q /dev/ttyACM0
		

clean:
	yes | rm -rf ${BUILD_DIR}
