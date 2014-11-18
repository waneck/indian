SOURCES=src/common.cpp src/i64.cpp src/pointer.cpp
CFLAGS= -fPIC -g
TARGET=../../ndll/Linux64/indian.ndll
OBJECTS=$(SOURCES:.cpp=.o)
CXXFLAGS += -fPIC
CXXFLAGS += -g

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LINK.cc) -shared $^ $(LOADLIBES) $(LDLIBS) -o $@

clean:
	rm -f $(OBJECTS)

.PHONY: all 


