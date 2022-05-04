ASM = gpasm
LINK= gplink

OBJDIR:=_build

OPT=--mpasm-compatible -c

OUT=temp.hex

vpath %.asm temp_18f_ds18b20 lcd4bit

FOLDERS = libs

$(OBJDIR)/%.o: %.asm
	@echo $(%.asm)
	$(ASM) $(OPT) $< -o $@

temp.hex: $(OBJDIR)/%.o
	$(ASM) $^ - o $(OUT)
