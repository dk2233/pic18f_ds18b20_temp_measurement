ASM = gpasm
LINK= gplink

OBJDIR:=_build

SCRIPT:=linker.lkr 

OPT=--mpasm-compatible -c

OUT=temp.hex

FILES = times.asm\
	   	init.asm\
	  	libs/lcd4bit.asm\
		ds18b20_driver.asm\
		temp_18f_ds18b20.asm
 
#libs/lcd4bit.asm

OBJECTS:= $(patsubst %.asm, %.o, $(FILES))
#OBJS := %(addprefix $(OBJDIR)/,
FOLDERS = libs



all: $(OUT)


%.o: %.asm
	@echo $(%.asm)
	$(ASM) $(OPT) $< -o $@

$(OUT): $(OBJECTS)
	@echo $^
	$(LINK) --map -s $(SCRIPT) -o $(OUT) $(OBJECTS) 

.PHONY: clean
clean:
	rm *.lst 
	rm *.o
	rm *.cod
	rm *.hex
