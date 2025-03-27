CC=clang
CFLAGS=-march=rv32i -nostdlib -O1

# Get all .c files
SRCS := $(wildcard *.c)

OBJS := $(SRCS:.c=.o)

# Strip .c to get the executable names
TGTS := $(SRCS:.c=.elf)

.PHONY: all

all: $(TGTS)
	llvm-objdump -d test.elf

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ 

%.elf: start.o %.o
	$(CC) $(CFLAGS) -Wl,-T,linker.ld -mno-relax $^ -o $@ 

start.o: start.S
	$(CC) -mno-relax -c $< -o $@

clean:
	rm -f $(TGTS) $(OBJS) start.o


	# ld.lld -T linker.ld -mno-relax -e _start $^ -o $@