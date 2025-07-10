CC = gcc
CFLAGS = -Wall
DEBUG_CFLAGS = $(CFLAGS) -g
SRC = main.c
OBJ = $(SRC:%.c=build/%.o)
BIN = ./bin
BINDIR = ./build/bin
TARGET = $(BIN)/main
DEBUG_TARGET = $(BINDIR)/main

all: $(TARGET) $(DEBUG_TARGET)

$(TARGET): $(OBJ)
	mkdir -p $(BIN)
	$(CC) $(CFLAGS) -o $@ $^
	strip $@

$(DEBUG_TARGET): $(OBJ)
	mkdir -p $(BINDIR)
	$(CC) $(DEBUG_CFLAGS) -o $@ $^

build/%.o: %.c
	mkdir -p build
	$(CC) $(DEBUG_CFLAGS) -c $< -o $@

clean:
	rm -rf build bin
