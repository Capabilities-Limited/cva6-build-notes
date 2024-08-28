SCRIPTS = create-ubuntu-vm.sh cva6-vm-from-scratch-notes.sh

all: $(SCRIPTS)

%.sh: %.md
	./extract-code.py $< -b -o $@
