prefix = /usr/local
bindir = $(prefix)/bin
CXX = g++
CC = gcc
CFLAGS = -Wall -pthread
LDFLAGS = -g -pthread

SOURCES = main.cpp reader.cpp write.cpp showev.cpp

ifneq ($(inotify),no)
	CFLAGS += -DWITH_INOTIFY
endif

all: build netevent devname

build:
	-mkdir build

build/%.o: %.cpp
	$(CXX) $(CFLAGS) -c -o $@ $*.cpp -MMD -MF build/$*.d -MT $@

build/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $*.c -MMD -MF build/$*.d -MT $@

netevent: $(patsubst %.cpp,build/%.o,$(SOURCES))
	$(CXX) $(LDFLAGS) -o $@ $^

devname: build/devname.o
	$(CC) -o $@ $^

install: all
	install -m 755 -p -t "$(DESTDIR)$(bindir)" netevent devname

clean:
	-rm -rf build
	-rm -f netevent devname

-include build/*.d
