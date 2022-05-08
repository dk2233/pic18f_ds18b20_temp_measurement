ASM = gpasm
LINK= gplink

OBJDIR:=_build

SCRIPT:=linker.lkr 

OPT= -c
#--mpasm-compatible
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

LINK_DEBUG = 
#-d


all: $(OUT)


%.o: %.asm
	@echo $(%.asm)
	$(ASM) $(OPT) $< -o $@

$(OUT): $(OBJECTS)
	@echo $^
	$(LINK) $(LINK_DEBUG)  --map -s $(SCRIPT) -o $(OUT) $(OBJECTS) 

.PHONY: clean
clean:
	rm *.lst 
	rm *.o
	rm *.cod
	rm *.hex
