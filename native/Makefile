SOURCES=src/common.cpp src/i64.cpp src/pointer.cpp

CFLAGS= -fPIC -g
LDFLAGS= -shared
TARGET=../ndll/Linux64/indian.ndll
OBJECTS: $(SOURCES:.cpp=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(FLAGS) $(CFLAGS) -o $(TARGET) $(OBJECTS)

.PHONY: all 


