SOURCES=src/common.cpp src/i64.cpp src/pointer.cpp
CFLAGS += -fPIC
CFLAGS += -g
CFLAGS += -Iexternal

OS=Linux64
TARGET=../../ndll/$(OS)/indian.ndll
OBJECTS=$(SOURCES:.cpp=.o)

CXXFLAGS += -fPIC
CXXFLAGS += -g
CXXFLAGS += -Iexternal

LDFLAGS += -lneko

all: $(TARGET)

$(TARGET): $(OBJECTS)
	mkdir -p ../../ndll/$(OS)
	$(LINK.cc) -shared $^ $(LOADLIBES) $(LDLIBS) -o $@

clean:
	rm -f $(OBJECTS)

.PHONY: all 


