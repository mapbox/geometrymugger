CC := $(CC)
CXX := $(CXX)
CXXFLAGS := $(CXXFLAGS) -Iinclude -Imason_packages/.link/include -std=c++11
RELEASE_FLAGS := -O3 -DNDEBUG
WARNING_FLAGS := -Wall -Wextra -Werror -Wsign-compare -Wfloat-equal -Wfloat-conversion -Wshadow -Wno-unsequenced
DEBUG_FLAGS := -g -O0 -DDEBUG -fno-inline-functions -fno-omit-frame-pointer
MASON ?= .mason/mason

default: test

$(MASON):
	git submodule update --init

mason_packages/.link/include/mapbox/geometry.hpp: $(MASON)
	$(MASON) install geometry 0.7.0 && $(MASON) link geometry 0.7.0
	$(MASON) install rapidjson 1.0.2 && $(MASON) link rapidjson 1.0.2

build-test: tests/* include/mapbox/geometry/* mason_packages/.link/include/mapbox/geometry.hpp Makefile
	$(CXX) $(RELEASE_FLAGS) tests/test.cpp tests/unit/*.cpp $(WARNING_FLAGS) $(CXXFLAGS) -I./tests -o test

build-debug: tests/* include/mapbox/geometry/* mason_packages/.link/include/mapbox/geometry.hpp Makefile
	$(CXX) $(DEBUG_FLAGS) tests/test.cpp tests/unit/*.cpp $(WARNING_FLAGS) $(CXXFLAGS) -I./tests -o test

build-fixture-tester:
	$(CXX) $(DEBUG_FLAGS) tests/fixture-tester.cpp $(WARNING_FLAGS) $(CXXFLAGS)  -o fixture-tester

test: build-test build-fixture-tester
	./test
	./tests/run-geometry-tests.sh ./fixture-tester

debug: build-debug build-fixture-tester
	./test
t	./tests/run-geometry-tests.sh ./fixture-tester

clean:
	rm -f test
	rm -f fixture-tester
	rm -rf ./mason_packages

indent:
	clang-format -i $(filter-out ./tests/catch.hpp, $(shell find . '(' -name '*.hpp' -o -name '*.cpp' ')' -type f -print))
