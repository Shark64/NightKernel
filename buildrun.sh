# let's make a kernel image and test it out! :D

# first we have to compile the kernel
nasm -f bin -o builds/kernel.sys kernel.asm

# now we mount the existing drive image to the folder VBoxDisk using a loop device to help
mkdir VBoxDisk
sudo losetup /dev/loop0 ./builds/Night.vdi -o 2129408
sudo mount /dev/loop0 ./VBoxDisk

# here we delete the old kernel image and copy the newly made one to the virtual floppy
sudo rm ./VBoxDisk/kernel.sys
sudo cp "builds/kernel.sys" "./VBoxDisk/kernel.sys"

# finally we unmount the newly modified floppy image
sudo umount ./VBoxDisk
sudo rmdir VBoxDisk

# destroy the loop device we set up
sudo losetup -d /dev/loop0

# fun! all done! ready to run, son!
virtualbox --startvm "Night" --debug-command-line --start-running
