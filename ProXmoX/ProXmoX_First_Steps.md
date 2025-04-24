lvremove

lvremove /dev/pve/data

lvresize -l +100%FREE /dev/pve/root


### Copy the ISO to a USB Drive:
### Copy the Windows 11 ISO file to a USB stick.
### Download the Windows Virtulization drivers from:
### https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers



### Find the USB Device by Running this command to list connected storage devices:
lsblk


/dev/sdc1 is mounted at /mnt/usb and is exFAT — this is your Ventoy data partition (where your ISO files live).

/dev/sdc2 is also mounted at /mnt/usb, and it's vfat — this is likely the Ventoy bootloader partition (small and not useful to you right now).



### Create a new mount point:
mkdir -p /mnt/ventoy


### Mount just the data partition (sdc1):
mount /dev/sdc1 /mnt/ventoy


### View your files:
ls -lh /mnt/ventoy


### You should now see all the ISO files you copied (like windows11.iso, etc.).
