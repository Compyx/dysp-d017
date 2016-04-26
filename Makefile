# vim: set noet ts=8 sw=8 sts=8 :
#
# Generic makefile for 64tass based projects


ASM=64tass
ASM_FLAGS=-C -a

X64=x64
X64_FLAGS=

TARGET=dysp-d017.prg
MAIN=main.asm
DEPS=Training.sid


all: $(TARGET)


$(TARGET) : $(MAIN) $(DEPS)
	$(ASM) $(ASM_FLAGS) -o $(TARGET) $(MAIN)

x64: $(TARGET)
	$(X64) $(X64_FLAGS) $(TARGET)


.PHONY: clean
clean:
	rm $(TARGET)

