# let's make a kernel image and test it out! :D

# first we have to compile the kernel
nasm -f bin -o builds/kernel.sys kernel.asm

# now we mount the existing floppy image
mkdir floppy
sudo mount "builds/images/night.img" -o umask=0 ./floppy

# here we delete the old kernel image and copy the newly made one to the virtual floppy
rm ./floppy/kernel.sys
cp "builds/kernel.sys" "./floppy/kernel.sys"

#finally we unmount the newly modified floppy image
sudo umount ./floppy
rmdir floppy

#fun! all done! ready to run, son!
imagepath=$(pwd)"/builds/images/night.img"
virtualbox --startvm "Night" --fda "$imagepath" --debug-command-line --start-running
