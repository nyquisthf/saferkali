#!/bin/bash

### your USB/Harddrive identification where you want to install the securekali.
drive="/dev/sdc"
### Edit the links below to new versions since I have no time to do that myself everyday. This is very important.
### Do not edit anything from here
### Allocating...
bootinstallpart=$drive'3';
encryptedpart=$drive'4';
### creating filestructure
echo 'creating filestructure';
mkdir files files/distro files/bootinstall files/mount; 
### Generating .iso
cd live-build-config
clear;
echo Choose your architecture
echo 1 - 32Bit 2 - 64Bit
read architecture;
if [ architecture==1 ]
then
lb config --architecture i386
else
lb config --architecture amd64
fi
### actually build
#lb build
### creating the partitions for the usb/hard drive
echo 'creating partitions now...';
dd if=files/distro/kali.iso of=$drive bs=4M;
echo "n\np\n\n+30M\nn\np\n\n\nw\n" | fdisk $drive
echo 'partitions created...';
### copy all files to the drive
clear;
echo 'copying install-on-boot files to nonencrypted partition...';
mount $bootinstallpart files/mount;
mv files/bootinstall/*  files/mount/;
cp scripts/* files/mount/;
umount files/mount;
clear;
echo 'creating encrypted filesystem...';
cryptsetup --verbose --verify-passphrase -h sha512 luksFormat $encryptedpart;
cryptsetup luksOpen $encryptedpart;
cryptsetup luksClose $encryptedpart;
#echo 'add nuke to encrypted filesystem...';
#cryptsetup luksAddNuke Storage;
rm -r files/;
