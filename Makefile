ASM = gpasm
LINK= gplink

OBJDIR:=_build

SCRIPT:=linker.lkr 

OPT= --mpasm-compatible -c
#
OUT=temp.hex

FILES = times.asm \
	   	init.asm \
	  	libs/lcd4bit.asm \
		libs/letters.asm \
		ds18b20_driver.asm \
		temp_18f_ds18b20.asm
 

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
	rm FOLDERS/*.o
	rm FOLDERS/*.lst
	rm *.cod
	rm *.hex
