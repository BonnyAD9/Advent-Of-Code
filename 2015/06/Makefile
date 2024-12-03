BUILD_TYPE=Debug
PARALEL=-j $(shell nproc)
MAIN=src/*.c # src/*.h src/**/*.c src/**/*.h
ALL=$(MAIN)
# gcc 13+ or clang 19+
CC=gcc

.PHONY: all
all: build

.PHONY: build
build:
	if [ ! -f build/Makefile ]; then \
		mkdir build; \
		cd build \
			&& cmake .. -DCMAKE_BUILD_TYPE=$(BUILD_TYPE); \
	fi
	cd build && $(MAKE) $(PARALEL)

.PHONY: run
run: build
	build/main

.PHONY: clean
clean:
	-cd build && $(MAKE) clean
