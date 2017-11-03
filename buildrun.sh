# let's make a kernel image and test it out! :D

# print size data for the files, just to satisfy the curiousity :)
du -b -c *.asm|tail -l

# first we have to compile the kernel
nasm -f bin -o kernel.sys kernel.asm

# now we mount the existing floppy image
mkdir floppy
sudo mount night.img -o umask=0 ./floppy

# here we delete the old kernel image and copy the newly made one to the virtual floppy
rm ./floppy/kernel.sys
cp kernel.sys ./floppy/kernel.sys

#finally we unmount the newly modified floppy image
sudo umount ./floppy
rmdir floppy

#fun! all done! ready to run, son!
imagepath=$(pwd)/night.img
virtualbox --startvm "Night" --fda "$imagepath" --debug-command-line --start-running
