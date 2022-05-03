ASM = gpasm
LINK= gplink

OBJDIR:=_build

OPT=--mpasm-compatible -c

OUT=temp.hex

FILE_LIST = temp_18f_ds18b20.asm 
#libs/lcd4bit.asm

FOLDERS = libs



all: $(OUT)


#$(OBJDIR)/%.o: %.asm
#	@echo $(%.asm)
#	$(ASM) $(OPT) $< -o $@
#
#
$(OUT): $(FILE_LIST)
	$(ASM) $^ -o $(OUT)
