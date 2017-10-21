#Makefile - A lot of stuff, all organized in one place
#
#[How to get make]
# sudo apt install make
#
#[How To use Makefile]
# In the command line type: make [function]

imagepath = ./floppy/kernel.sys

all: 
	nasm kernel.asm -f bin -o kernel.sys
	
	#mount floppy
	mkdir floppy
	sudo mount night.img -o umask=0 ./floppy 
	
	#Delete old stuff
	rm -r ./floppy/kernel.sys
	cp -i kernel.sys ./floppy/kernel.sys
	
	#unmount
	sudo umount ./floppy
	rmdir floppy
	
	#fun! all done! ready to run, son!
	virtualbox --startvm "Night" --fda "$(imagepath)" --debug-command-line --start-running
	
edit:
	notepadqq kernel.asm *.asm