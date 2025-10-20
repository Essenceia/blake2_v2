BUILD_DIR:=artifact
PROJECT_NAME:=blake2s_asic_firmeware
SRC:=$(wildcard *.c) $(wildcard *.h)

${BUILD_DIR}:
	PROJECT_NAME=${PROJECT_NAME} cmake -S . ${BUILD_DIR}

.PHONY: setup build flash

setup: ${BUILD_DIR}

build: setup ${SRC} CMakeLists.txt
	cmake --build ${BUILD_DIR} --target ${PROJECT_NAME}
	
flash:
	cp ${BUILD_DIR}/${PROJECT_NAME}.uf2 /mnt/rpi

clean:
	yes | rm -rf ${BUILD_DIR}
